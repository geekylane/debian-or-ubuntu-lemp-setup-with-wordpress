sudo apt update -y & sudo apt install -y nginx && sudo apt install -y mysql-server

sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';"
sudo mysql -u root -ppassword -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
sudo mysql -u root -ppassword -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -u root -ppassword -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';"
sudo mysql -u root -ppassword -e "FLUSH PRIVILEGES;"

sudo apt install -y php-fpm php-mysql
sudo touch /etc/nginx/sites-available/website
sudo cat default.conf > /etc/nginx/sites-available/website
sudo ln -s /etc/nginx/sites-available/website /etc/nginx/sites-enabled/
sudo unlink /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx

sudo mysql -u root -ppassword -e "CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
sudo mysql -u root -ppassword -e "GRANT ALL ON wordpress.* TO 'wordpressuser'@'localhost' IDENTIFIED BY 'password';"
sudo mysql -u root -ppassword -e "FLUSH PRIVILEGES;"

sudo apt install -y php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip
sudo systemctl restart php7.2-fpm
sudo systemctl reload nginx

cd /tmp && curl -LO https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php

sudo cp -a /tmp/wordpress/. /var/www/html
sudo chown -R www-data:www-data /var/www/html

cd /var/www/html
sudo sed -i 's/database_name_here/wordpress/g' wp-config.php
sudo sed -i 's/username_here/wordpressuser/g' wp-config.php
sudo sed -i 's/password_here/password/g' wp-config.php
sudo sed -i '38 a define('FS_METHOD', 'direct');' wp-config.php

cd /var/www/html
sudo curl http://api.wordpress.org/secret-key/1.1/salt/ > wp_keys.txt
sudo sed -i.bak -e '/AUTH_KEY/d' -e '/SECURE_AUTH_KEY/d' -e '/LOGGED_IN_KEY/d' -e '/NONCE_KEY/d' -e '/AUTH_SALT/d' -e '/SECURE_AUTH_SALT/d' -e '/LOGGED_IN_SALT/d' -e '/NONCE_SALT/d' wp-config.php
sudo cat wp_keys.txt >> wp-config.php
sudo rm wp_keys.txt