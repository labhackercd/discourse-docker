FROM discourse/base:2.0.20171126

COPY ./site_settings.yml /var/www/discourse/config/

WORKDIR /var/www/discourse