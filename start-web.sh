#!/bin/bash

sed -i -e "s/DISCOURSE_CONTACT_EMAIL/${DISCOURSE_CONTACT_EMAIL}/g" config/site_settings.yml
sed -i -e "s/DISCOURSE_CONTACT_URL/${DISCOURSE_CONTACT_URL}/g" config/site_settings.yml
sed -i -e "s/DISCOURSE_NOTIFICATION_EMAIL/${DISCOURSE_NOTIFICATION_EMAIL}/g" config/site_settings.yml
sed -i -e "s/DISCOURSE_LOGO_URL/${DISCOURSE_LOGO_URL}/g" config/site_settings.yml
sed -i -e "s/DISCOURSE_SMALL_LOGO_URL/${DISCOURSE_SMALL_LOGO_URL}/g" config/site_settings.yml
sed -i -e "s/DISCOURSE_FAVICON_URL/${DISCOURSE_FAVICON_URL}/g" config/site_settings.yml
sed -i -e "s/DISCOURSE_APPLE_TOUCH_ICON_URL/${DISCOURSE_APPLE_TOUCH_ICON_URL}/g" config/site_settings.yml
sed -i -e "s/DISCOURSE_SSO_URL/${DISCOURSE_SSO_URL}/g" config/site_settings.yml
sed -i -e "s/DISCOURSE_SSO_SECRET/${DISCOURSE_SSO_SECRET}/g" config/site_settings.yml
sed -i -e "s/DISCOURSE_FORCE_HOSTNAME/${DISCOURSE_FORCE_HOSTNAME}/g" config/site_settings.yml

while true; do
    PG_STATUS=`PGPASSWORD=$DISCOURSE_DB_PASSWORD psql -U $DISCOURSE_DB_USERNAME  -w -h $DISCOURSE_DB_HOST -c '\l \q' | grep postgres | wc -l`
    if ! [ "$PG_STATUS" -eq "0" ]; then
       break
    fi
    echo "Waiting Database Setup"
    sleep 10
done

bundle exec rake db:create db:migrate
bundle exec rake assets:precompile
bundle exec rake admin:create

bundle exec sidekiq -e production -d -l sidekiq.log
bundle exec unicorn