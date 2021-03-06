#########################################
# Name: wp_setup.sh
# Written by: Cliff Ching
# Written date: 4 July 2018
# Updated By:
# Updated Date:
# Description: To setup wordpress using LAMP of centos 7 native
# Run this in centos 7 using root
#########################################


WP_DOMAIN="mywordpress.com"
WP_ADMIN_USERNAME="admin"
WP_ADMIN_PASSWORD="adminpassword"
WP_ADMIN_EMAIL="admin@admin.com"
WP_DB_NAME="wordpress"
WP_DB_USERNAME="wordpressuser"
WP_DB_PASSWORD="password"
WP_PATH="/var/www/html/wordpress"

### Validate if root is used ###
if [ `whoami` != "root" ] ; then
echo "Please run ${0} as root"
exit 0
fi

### Install the LAMP requirements for the centos7 ###
echo "Installing required LAMP components"
yum install httpd mariadb-server mariadb php php-mysql -y
echo "Instaling LAMP completed"
echo ""
sleep 1

### startup and systemctl auto startup ###
echo -n "Startup http and mariadb"
systemctl enable httpd.service mariadb.service
systemctl start httpd.service mariadb.service
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --reload
echo "Startup Done"
echo ""
sleep 1

### Create DB info for wordpress ###
echo "Create account and database in Mariadb"
mysql -u root << EOF
CREATE DATABASE ${WP_DB_NAME};
CREATE USER ${WP_DB_USERNAME}@localhost IDENTIFIED BY '${WP_DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${WP_DB_NAME}.* TO ${WP_DB_USERNAME}@localhost IDENTIFIED BY '${WP_DB_PASSWORD}';
FLUSH PRIVILEGES;
EOF
echo "MariaDB setup creation completed"
systemctl restart mariadb.service
echo ""
sleep 1

### Download wordpress from internet ###
echo "Downloading wordpress packages from internet"
cd /var/www/html
curl -O https://wordpress.org/latest.tar.gz
echo "Download completed"
echo ""
sleep 1

### Setup and configuring wordpress ###
echo "Setup and configuring wordpress"
tar xfz latest.tar.gz
cd $WP_PATH
echo "Configuring Account Credentials"
test -f wp-config.php || cp -p wp-config-sample.php wp-config.php
sed -i 's/database_name_here/wordpress/g' wp-config.php
sed -i 's/username_here/wordpressuser/g' wp-config.php
sed -i 's/password_here/password/g' wp-config.php
echo "define('FS_METHOD', 'direct');" >> wp-config.php

chown -R apache:apache ${WP_PATH}
systemctl restart httpd.service
echo "Wordpress configuration completed"
echo ""
sleep 1

### Complete Wordpress admin user setup ###
echo "Setting Up WordPress user for the first time..."
curl "http://127.0.0.1/wordpress/wp-admin/install.php?step=2" \
--data-urlencode "weblog_title=${WP_DOMAIN}" \
--data-urlencode "user_name=${WP_ADMIN_USERNAME}" \
--data-urlencode "admin_email=${WP_ADMIN_EMAIL}" \
--data-urlencode "admin_password=${WP_ADMIN_PASSWORD}" \
--data-urlencode "admin_password2=${WP_ADMIN_PASSWORD}" \
--data-urlencode "pw_weak=1"
echo "Wordpress Account Setup Completed"
echo ""
sleep 1

### Validate the wordpress page ###
curl -isk http://127.0.0.1/wordpress/

### To further Edit these are the suggestions for improvements:
### - Do a search at /var/www/html/wordpress and search 127.0.0.1
### and perform a sed replace for 127.0.0.1 to your desired apache IP or WP_Domain Name
### - Apache config should also startup to listen only on your desired IP
### - MariaDB should also be harden after setup completes
### - Apache should also be harden to allow only required core modules to startup
### such as mod_host, mod_rewrite, and others that wordpress may required
### - wp-config should also turn off define('FS_METHOD', 'direct') and restart to prevent php direct update
### for fear for possibility of vulnerability modification
### - Website should generate a cert for SSL could use selfsign as a temporary means but ultimately to use purchased SSL

echo "Wordpress Setup Completed"
