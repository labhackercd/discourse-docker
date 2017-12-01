desc "create admin using environment variables"
task "create_admin" => :environment do
  require 'highline/import'

  email = ENV['ADMIN_EMAIL']
  password = ENV['ADMIN_PASSWORD']
  username = ENV['ADMIN_USERNAME']

  if [email, password, username].include? nil
    abort("Missing environment variables!")
  else
    puts "Creating admin user"
    existing_user = User.find_by_email(email)
    if existing_user
      admin = existing_user
    else
      admin = User.new
    end
    admin.password = password
    admin.username = username
    admin.email = email
    admin.active = true
    admin.grant_admin!
    admin.change_trust_level!(4)
    admin.email_tokens.update_all confirmed: true
    admin.activate
    puts "Done!"
  end
end
