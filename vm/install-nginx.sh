#!/usr/bin/env bash

WEB_ROOT="/var/www"
PHP_VERSIONS=( "5.6" "7.1" "7.2" )

# Install nginx
sudo add-apt-repository ppa:nginx/development -y
sudo apt-get install nginx -y

# Copy default ssl certificates
[ ! -d "/etc/ssl/custom" ] && \
sudo mkdir /etc/ssl/custom
sudo cp ./config/ssl/* /etc/ssl/custom

sudo cp ./config/ssl/ca.crt /usr/local/share/ca-certificates
sudo update-ca-certificates

# Copy default configuration files
[ ! -d "/etc/nginx/custom" ] && \
sudo mkdir /etc/nginx/custom

sudo cp ./config/nginx/index.conf /etc/nginx/conf.d
sudo cp ./config/nginx/gzip.conf /etc/nginx/conf.d
sudo cp ./config/nginx/uploads.conf /etc/nginx/conf.d
sudo cp ./config/nginx/xdebug.conf /etc/nginx/conf.d

sudo cp ./config/nginx/custom/detect-php.conf /etc/nginx/custom/detect-php.conf
sudo cp ./config/nginx/custom/ssl.conf /etc/nginx/custom/ssl.conf
sudo cp ./config/nginx/custom/static.conf /etc/nginx/custom/static.conf
sudo cp ./config/nginx/custom/php.conf /etc/nginx/custom/php.conf
sudo cp ./config/nginx/custom/security.conf /etc/nginx/custom/security.conf
sudo cp ./config/nginx/custom/cors.conf /etc/nginx/custom/cors.conf

# Create the upstreams
sudo touch /etc/nginx/conf.d/upstream.conf
for version in "${PHP_VERSIONS[@]}"
do
    sed "s/{version}/${version}/g" ./config/nginx/upstream.stub | sudo tee -a /etc/nginx/conf.d/upstream.conf > /dev/null
done

# Remove default site
sudo rm -f /etc/nginx/sites-available/default
sudo rm -f /etc/nginx/sites-enabled/default

# Copy the new ones
sudo cp ./config/nginx/sites/default.conf /etc/nginx/sites-available/default
sudo cp ./config/nginx/sites/search.conf /etc/nginx/sites-available/search
sudo cp ./config/nginx/sites/mail.conf /etc/nginx/sites-available/mail

# Enable default config
sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/search /etc/nginx/sites-enabled/search
sudo ln -s /etc/nginx/sites-available/mail /etc/nginx/sites-enabled/mail

# Make web root
[ ! -d "${WEB_ROOT}/vhosts" ] && \
sudo mkdir "${WEB_ROOT}/vhosts"

# Ensure web root is under correct ownership
sudo chown $USER:$USER "${WEB_ROOT}/vhosts"
sudo chmod 0755 "${WEB_ROOT}/vhosts"

# Restart
sudo service nginx restart
