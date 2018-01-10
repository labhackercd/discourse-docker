
desc "invite an admin to this discourse instance"
task "admin:invite", [:email] => [:environment] do |_, args|
  email = args[:email]
  if !email || email !~ /@/
    puts "ERROR: Expecting rake admin:invite[some@email.com]"
    exit 1
  end

  unless user = User.find_by_email(email)
    puts "Creating new account!"
    user = User.new(email: email)
    user.password = SecureRandom.hex
    user.username = UserNameSuggester.suggest(user.email)
  end

  user.active = true
  user.save!

  puts "Granting admin!"
  user.grant_admin!
  user.change_trust_level!(4)
  user.email_tokens.update_all confirmed: true

  puts "Sending email!"
  email_token = user.email_tokens.create(email: user.email)
  Jobs.enqueue(:user_email, type: :account_created, user_id: user.id, email_token: email_token.token)
end

desc "Creates a forum administrator"
task "admin:create" => :environment do
  require 'highline/import'

  email = ENV['ADMIN_EMAIL']
  password = ENV['ADMIN_PASSWORD']
  username = ENV['ADMIN_USERNAME']
  existing_user = User.find_by_email(email)

  if [email, password, username].include? nil
    abort("Missing environment variables!")
  end

  # check if user account already exixts
  if existing_user
    # user already exists, ask for password reset
    say "\nUser already exists. Updating password."
    admin = existing_user
    admin.password = password
  else
    # create new user
    admin = User.new
    admin.email = email
    admin.username = username
    admin.password = password
  end

  # save/update user account
  saved = admin.save
  if !saved
    abort(admin.errors.full_messages.join("\n"))
  end

  say "\nEnsuring account is active!"
  admin.active = true
  admin.save

  if existing_user
    say("\nAccount updated successfully!")
  else
    say("\nAccount created successfully with username #{admin.username}")
  end

  # grant admin privileges
  say("\nGrant Admin privileges...")
  admin.grant_admin!
  admin.change_trust_level!(4)
  admin.email_tokens.update_all confirmed: true
  admin.activate

  say("\nYour account now has Admin privileges!")
end