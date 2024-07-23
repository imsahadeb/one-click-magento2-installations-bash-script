#!/bin/bash

# Update and upgrade the system

echo "Updating and upgrading the system..."
sudo apt update && sudo apt upgrade -y

# Install Apache and MySQL
echo "Installing Apache and MySQL..."
sudo apt install -y zip apache2 mysql-server

# Secure MySQL installation and create database and user
echo "Securing MySQL installation and creating database and user..."
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password'; FLUSH PRIVILEGES;"
sudo mysql -u root -ppassword -e "CREATE DATABASE magento;"
sudo mysql -u root -ppassword -e "CREATE USER 'magento_user'@'localhost' IDENTIFIED BY 'password';"
sudo mysql -u root -ppassword -e "GRANT ALL PRIVILEGES ON magento.* TO 'magento_user'@'localhost';"
sudo mysql -u root -ppassword -e "FLUSH PRIVILEGES;"

# Install PHP and required extensions
echo "Installing PHP and required extensions..."
sudo apt install -y php libapache2-mod-php php-mysql php-mbstring php-bcmath php-zip php-intl php-soap php-gd php-curl php-cli php-xml php-xmlrpc php-gmp php-common

# Detect the installed PHP version
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION . '.' . PHP_MINOR_VERSION;")
echo "Detected PHP version: $PHP_VERSION"

# Update php.ini settings
echo "Updating php.ini settings..."
sudo sed -i "s/memory_limit = .*/memory_limit = 2G/" /etc/php/${PHP_VERSION}/cli/php.ini
sudo sed -i "s/;realpath_cache_size = .*/realpath_cache_size = 10M/" /etc/php/${PHP_VERSION}/cli/php.ini
sudo sed -i "s/;realpath_cache_ttl = .*/realpath_cache_ttl = 7200/" /etc/php/${PHP_VERSION}/cli/php.ini

# Restart Apache to apply changes
echo "Restarting Apache to apply changes..."
sudo systemctl restart apache2

# Install Elasticsearch 7.x
echo "Installing Elasticsearch 7.x..."
sudo apt install -y openjdk-11-jdk apt-transport-https
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt update && sudo apt install -y elasticsearch=7.10.2
sudo systemctl start elasticsearch
sudo systemctl enable elasticsearch

# Install Composer
echo "Installing Composer..."
curl -sS https://getcomposer.org/installer -o composer-setup.php
sudo php composer-setup.php --install-dir=/usr/bin --filename=composer
rm composer-setup.php

# Set Magento authentication keys
echo "Setting Magento authentication keys..."
COMPOSER_AUTH='{
    "http-basic": {
        "repo.magento.com": {
            "username": "YOUR_PUBLIC_KEY",
            "password": "YOUR_PRIVATE_KEY"
        }
    }
}'

echo "$COMPOSER_AUTH" > ~/.composer/auth.json

CURRENT_USER=$(whoami)
echo "Adding current user ($CURRENT_USER) to www-data group..."
sudo usermod -aG www-data $CURRENT_USER

# Download and set up Magento
echo "Downloading and setting up Magento..."
sudo mkdir -p /var/www/html/magento
sudo chown -R www-data:www-data /var/www/html/magento/
sudo chmod -R g+rw /var/www/html/magento/
sudo chmod g+s /var/www/html/magento/
cd /var/www/html/magento
composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition .

# Configure Apache for Magento
echo "Configuring Apache for Magento..."
sudo sed -i 's|/var/www/html|/var/www/html/magento|g' /etc/apache2/sites-available/000-default.conf
sudo sed -i 's|#ServerName www.example.com|ServerName 13.201.193.117|g' /etc/apache2/sites-available/000-default.conf
sudo bash -c 'cat >> /etc/apache2/sites-available/000-default.conf <<EOF
<Directory /var/www/html/magento/>
    Options Indexes FollowSymLinks MultiViews
    AllowOverride All
    Order allow,deny
    allow from all
</Directory>
EOF'

sudo a2dissite 000-default
sudo a2enmod rewrite
sudo systemctl restart apache2

# Install Magento
echo "Installing Magento..."
cd /var/www/html/magento
sudo bin/magento setup:install \
--base-url=http://13.201.193.117 \
--db-host=localhost \
--db-name=magento \
--db-user=magento_user \
--db-password=password \
--admin-firstname=Admin \
--admin-lastname=Admin \
--admin-email=admin@admin.com \
--admin-user=admin \
--admin-password=admin123 \
--language=en_US \
--currency=USD \
--timezone=America/Chicago \
--use-rewrites=1

# Set Magento to developer mode and install sample data
echo "Setting Magento to developer mode and installing sample data..."
sudo bin/magento deploy:mode:set developer
sudo rm -rf generated/code/* generated/metadata/*
sudo bin/magento sampledata:deploy
sudo bin/magento setup:upgrade
sudo bin/magento cache:clean
sudo bin/magento cache:flush

# Additional configurations
echo "Applying additional configurations..."
sudo bin/magento config:set web/secure/use_in_frontend 1
sudo bin/magento config:set web/secure/use_in_adminhtml 1
sudo chown -R www-data:www-data /var/www/html/magento/
echo "Magento installation completed successfully!"
