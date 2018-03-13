# SETTING PHP-7.1
add-apt-repository ppa:ondrej/php
apt-get update
apt-get install -y python-software-properties software-properties-common
# Install packages
apt-get install -y php7.1 php7.1-fpm
apt-get install -y php7.1-mysql
apt-get install -y mcrypt php7.1-mcrypt
apt-get install -y php7.1-cli php7.1-curl php7.1-mbstring php7.1-xml php7.1-mysql
apt-get install -y php7.1-json php7.1-cgi php7.1-gd php-imagick php7.1-bz2 php7.1-zip

# SETTING MySQL
# (username: root) ~ (password: password)
sudo debconf-set-selections <<< 'mysql-server-5.6 mysql-server/root_password password password'
sudo debconf-set-selections <<< 'mysql-server-5.6 mysql-server/root_password_again password password'

# Installing packages
apt-get install -y mysql-server mysql-client mysql-common

mysql -uroot -ppassword -e "CREATE DATABASE IF NOT EXISTS dbq;";
mysql -uroot -ppassword -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'password';"
mysql -uroot -ppassword -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY 'password';"

sudo service mysql restart

# SETTING NGINX
apt-get install -y nginx

echo '' > /etc/nginx/sites-available/default
cat >> /etc/nginx/sites-available/default <<'EOF'
server {
	# Server listening port
	listen 80;

	# Server domain or IP
	server_name localhost;

	# Root and index files
	root /var/www/web/public;
	index index.php index.html index.htm;	

	# Urls to attempt
	location / {
                try_files $uri $uri/ /index.php?$query_string;
        }

	# Configure PHP FPM
	location ~* \.php$ {
		fastcgi_pass unix:/var/run/php/php7.1-fpm.sock;
		fastcgi_index index.php;
		fastcgi_split_path_info ^(.+\.php)(.*)$;
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
		include /etc/nginx/fastcgi_params;
	}

	# Debugging
	access_log /var/log/nginx/localhost_access.log;
	error_log /var/log/nginx/localhost_error.log;
	rewrite_log on;
}
EOF

service nginx restart
service php7.1-fpm restart

# SETTING COMPOSER

curl -s https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# SETUP LARAVEL
cd /var/www/web
cp .env.example .env

sed -i "s/DB_DATABASE=blog/DB_DATABASE=dbq/g" .env
sed -i "s/DB_USERNAME=root/DB_USERNAME=root/g" .env
sed -i "s/DB_PASSWORD=/DB_PASSWORD=password/g" .env

composer install

php artisan migrate

php artisan key:generate

# SET UP MYSQL FOR REMOTE CONNECTION
echo "bind-address  = 0.0.0.0" >> /etc/mysql/mysql.conf.d/mysqld.cnf
service mysql restart
