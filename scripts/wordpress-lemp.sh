#!/bin/bash

#####################################################
#Script to confiruge Server, WebServer and WordPress#
#####################################################
#PATH variables
ABSPATH=$(readlink -f $0)
ABSDIR=$(dirname $ABSPATH)
SCRIPT=$ABSDIR
STECK=$ABSDIR/stecks

#Import Main Functions for script
source $SCRIPT/functions.sh

required_pkgs="bar nano htop apache2 php mysql-server phpmyadmin wget curl php-curl zip unzip"
root_check
#creating user
echo -e "${YELLOW}Creating website folder...${NC}"

  #echo -e "${YELLOW}Please, enter new username: ${NC}"
  #read 
  echo -e "${YELLOW}Please enter website name: ${NC}"
  read websitename
  #groupadd $
  #adduser --home /var/www/$websitename --ingroup $ 
  mkdir /var/www/$websitename
  chown -R : /var/www/$websitename
  echo -e "${GREEN}User, group and home folder were succesfully created!
  Username: 
  Group: 
  Home folder: /var/www/$websitename
  Website folder: /var/www/$websitename ${NC}"

#configuring apache2
echo -e "${YELLOW}Now we going to configure apache2 for your domain name & website root folder...${NC}"

read -r -p "Do you want to configure Apache2 automatically? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 

  echo -e "Please, provide us with your domain name: "
  read domain_name
  echo -e "Please, provide us with your email: "
  read domain_email
  cat >/etc/apache2/sites-available/$domain_name.conf <<EOL
  <VirtualHost *:80>
        ServerAdmin $domain_email
        ServerName $domain_name
        ServerAlias www.$domain_name
        DocumentRoot /var/www/$websitename/
        <Directory />
                Options +FollowSymLinks
                AllowOverride All
        </Directory>
        <Directory /var/www/$websitename/>
                Options -Indexes +FollowSymLinks +MultiViews
                AllowOverride All
                Order allow,deny
                allow from all
        </Directory>

        ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
        <Directory "/usr/lib/cgi-bin">
                AllowOverride None
                Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
                Order allow,deny
                Allow from all
        </Directory>

        ErrorLog ${APACHE_LOG_DIR}/error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL
	a2dissite 000-default
    a2ensite $domain_name
    service apache2 restart
    P_IP="`wget http://ipinfo.io/ip -qO -`"

    echo -e "${GREEN}Apache2 config was updated!
    New config file was created: /etc/apache2/sites-available/$domain_name.conf
    Domain was set to: $domain_name
    Admin email was set to: $domain_email
    Root folder was set to: /var/www/$websitename/
    Option Indexes was set to: -Indexes (to close directory listing)
    Your server public IP is: $P_IP (Please, set this IP into your domain name 'A' record)
    Website was activated & apache2 service reloaded!
    ${NC}"

        ;;
    *)

  echo -e "${RED}WARNING! Apache2 was not configured properly, you can do this manually or re run our script.${NC}"

        ;;
esac


#downloading WordPress, unpacking, adding basic pack of plugins, creating .htaccess with optimal & secure configuration
echo -e "${YELLOW}On this step we going to download latest version of WordPress with EN or RUS language, set optimal & secure configuration and add basic set of plugins...${NC}"

read -r -p "Do you want to install WordPress & automatically set optimal and secure configuration with basic set of plugins? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 

  echo -e "${GREEN}Please, choose WordPress language you need (set RUS or ENG): "
  read wordpress_lang

  if [ "$wordpress_lang" == 'RUS' ];
    then
    wget https://ru.wordpress.org/latest-ru_RU.zip -O /tmp/$wordpress_lang.zip
  else
    wget https://wordpress.org/latest.zip -O /tmp/$wordpress_lang.zip
  fi

  echo -e "Unpacking WordPress into website home directory..."
  sleep 5
  unzip /tmp/$wordpress_lang.zip -d /var/www/$websitename
  mv /var/www/$websitename/wordpress/* /var/www/$websitename
  rm -rf /var/www/$websitename/wordpress
  rm /tmp/$wordpress_lang.zip
  mkdir /var/www/$websitename/wp-content/uploads
  chmod -R 777 /var/www/$websitename/wp-content/uploads
        ;;
    *)

  echo -e "${RED}WordPress and plugins were not downloaded & installed. You can do this manually or re run this script.${NC}"

        ;;
esac
#creating of swap
echo -e "On next step we going to create SWAP (it should be your RAM x2)..."

read -r -p "Do you need SWAP? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 

  RAM="`free -m | grep Mem | awk '{print $2}'`"
  swap_allowed=$(($RAM * 2))
  swap=$swap_allowed"M"
  fallocate -l $swap /var/swap.img
  chmod 600 /var/swap.img
  mkswap /var/swap.img
  swapon /var/swap.img

  echo -e "${GREEN}RAM detected: $RAM
  Swap was created: $swap${NC}"
  sleep 5

        ;;
    *)

  echo -e "${RED}You didn't create any swap for faster system working. You can do this manually or rerun this script.${NC}"

        ;;
esac

#creation of secure .htaccess
echo -e "${YELLOW}Creation of secure .htaccess file...${NC}"
sleep 3
cat >/var/www/$websitename/.htaccess <<EOL
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]

RewriteCond %{query_string} concat.*\( [NC,OR]
RewriteCond %{query_string} union.*select.*\( [NC,OR]
RewriteCond %{query_string} union.*all.*select [NC]
RewriteRule ^(.*)$ index.php [F,L]

RewriteCond %{QUERY_STRING} base64_encode[^(]*\([^)]*\) [OR]
RewriteCond %{QUERY_STRING} (<|%3C)([^s]*s)+cript.*(>|%3E) [NC,OR]
</IfModule>

<Files .htaccess>
Order Allow,Deny
Deny from all
</Files>

<Files wp-config.php>
Order Allow,Deny
Deny from all
</Files>

<Files wp-config-sample.php>
Order Allow,Deny
Deny from all
</Files>

<Files readme.html>
Order Allow,Deny
Deny from all
</Files>

<Files xmlrpc.php>
Order allow,deny
Deny from all
</files>

# Gzip
<ifModule mod_deflate.c>
AddOutputFilterByType DEFLATE text/text text/html text/plain text/xml text/css application/x-javascript application/javascript text/javascript
</ifModule>

Options +FollowSymLinks -Indexes

EOL

chmod 644 /var/www/$websitename/.htaccess

echo -e "${GREEN}.htaccess file was succesfully created!${NC}"

#cration of robots.txt
echo -e "${YELLOW}Creation of robots.txt file...${NC}"
sleep 3
cat >/var/www/$websitename/robots.txt <<EOL
User-agent: *
Disallow: /cgi-bin
Disallow: /wp-admin/
Disallow: /wp-includes/
Disallow: /wp-content/
Disallow: /wp-content/plugins/
Disallow: /wp-content/themes/
Disallow: /trackback
Disallow: */trackback
Disallow: */*/trackback
Disallow: */*/feed/*/
Disallow: */feed
Disallow: /*?*
Disallow: /tag
Disallow: /?author=*
EOL

echo -e "${GREEN}File robots.txt was succesfully created!
Setting correct rights on user's home directory and 755 rights on robots.txt${NC}"
sleep 3

chmod 755 /var/www/$websitename/robots.txt

echo -e "${GREEN} Configuring apache2 prefork & worker modules...${NC}"
sleep 3
cat >/etc/apache2/mods-available/mpm_prefork.conf <<EOL
<IfModule mpm_prefork_module>
	StartServers		  1
	MinSpareServers		  1
	MaxSpareServers		  3
	MaxRequestWorkers	  10
	MaxConnectionsPerChild    3000
</IfModule>
EOL

cat > /etc/apache2/mods-available/mpm_worker.conf <<EOL
<IfModule mpm_worker_module>
	StartServers	         1
	MinSpareThreads		 5
	MaxSpareThreads		 15
	ThreadLimit		 25
	ThreadsPerChild		 5
	MaxRequestWorkers	 25
	MaxConnectionsPerChild   200
</IfModule>
EOL

a2dismod status

echo -e "${GREEN}Configuration of apache mods was succesfully finished!
Restarting Apache & MySQL services...${NC}"

service apache2 restart
service mysql restart

echo -e "${GREEN}Services succesfully restarted!${NC}"
sleep 3

echo -e "${GREEN}Adding user & database for WordPress, setting wp-config.php...${NC}"
#Check IF script have access to mysql
sudo mysql -e "SHOW DATABASES;"  > /dev/null 2>&1
if [ "$?" != "0" ]; then
echo -e "${YELLOW} Can not access Mysql Databases! ${NC}"
read -p "Please enter ROOT password for MySQL: " root_pass
echo -e "${YELLOW} Now we create new script user tommi with root privilegies, after all this user will be autoremoved ${NC}"
read -p "Please enter NEW password for script user (tommi): " passwd
mysql -uroot -p$root_pass -e "CREATE USER 'tommi'@'localhost' IDENTIFIED WITH mysql_native_password;" 2>/dev/null
mysql -uroot -p$root_pass  -e "ALTER USER 'tommi'@'localhost' IDENTIFIED BY '$passwd';" 2>/dev/null
mysql -uroot -p$root_pass -e "GRANT ALL PRIVILEGES ON *.* TO tommi@localhost WITH GRANT OPTION;" 2>/dev/null
else
echo  -e "${YELLOW} Now we create new script user tommi with root privilegies, after all this user will be autoremoved ${NC}"
read -p "Please enter NEW password for script user (tommi): " passwd
sudo mysql -e "CREATE USER 'tommi'@'localhost' IDENTIFIED WITH mysql_native_password;" 2>/dev/null
sudo mysql -e "ALTER USER 'tommi'@'localhost' IDENTIFIED BY '$passwd';" 2>/dev/null
sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO tommi@localhost WITH GRANT OPTION;" 2>/dev/null
fi
#Credentalies create
function create_muser_db() {
echo "Do You Want to create user and database for your purposes?"
read -p "Enter y or yes to continue, enter whatever to skip: " confirm
if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
        sudo mysql -utommi -p$passwd -e "UNINSTALL COMPONENT 'file://component_validate_password';" 2>/dev/null

        read -p "Enter USERNAME for MYSQL USER: " user
        sudo mysql -utommi -p$passwd  -e "CREATE USER '$user'@'localhost' IDENTIFIED WITH mysql_native_password;" 2>/dev/null

        read -p "Enter PASSWORD for MYSQL USER: " pass
        echo "Creating user $user with password $pass ............."
        sudo mysql -utommi -p$passwd  -e "ALTER USER '$user'@'localhost' IDENTIFIED BY '$pass';" 2>/dev/null
        sleep 1

        read -p "Enter DATABASE NAME: " database
        echo "Creating DB $database and grant all priveligies to $user ............."
        sleep 1

        sudo mysql -utommi -p$passwd  -e "CREATE DATABASE $database CHARACTER SET utf8 COLLATE utf8_general_ci;"  2>/dev/null
        sudo mysql -utommi -p$passwd  -e "GRANT ALL PRIVILEGES ON $database.* TO $user@localhost WITH GRANT OPTION;" 2>/dev/null

        result_mysql="\n**********Your Data:**********  \n user: $user@localhost \n password: $pass \n database with full access: $database \n\n Enjoy!\n**********Your Data:**********"
        echo "$result_mysql" > mysql_credentialies.txt
	echo -e "$result_mysql"
	sudo mysql -uroot -p$root_pass -e "DROP USER tommi@localhost;"
fi
}

create_muser_db

SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
cat > /var/www/$websitename/wp-config.php <<EOL
<?php

define('DB_NAME', '$database');

define('DB_USER', '$user');

define('DB_PASSWORD', '$pass');

define('DB_HOST', 'localhost');

define('DB_CHARSET', 'utf8');

define('DB_COLLATE', '');

$SALT

\$table_prefix  = 'wp_';

define('WP_DEBUG', false);

if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');

?>

EOL

chown -R www-data:www-data /var/www/$websitename
echo -e "${GREEN}Database user, database and wp-config.php were succesfully created & configured!${NC}"
sleep 3


modsec_ok=$(dpkg-query -W --showformat='${Status}\n' libapache2-mod-security2|grep -i "install ok installed")
if [ "$modsec_ok" == "install ok installed"  ]; then

echo "Do You Want To Add some exceptions in ModSec for correct wordpress work?"
read -p "Enter y or yes to continue, enter whatever to skip: " confirm

        if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then

                sed -i -E '/<\/VirtualHost>/i \        <LocationMatch "/wp-login.php/*">\n           SecRuleEngine Off \n\        </LocationMatch> \n' /etc/apache2/sites-enabled/unga-bonga.com.conf

                sed -i -E '/<\/VirtualHost>/i \        <LocationMatch "/wp-admin/page.php">\n        SecRuleRemoveById 300013 300014 300015 300016 300017\n\       </LocationMatch> \n' /etc/apache2/sites-enabled>

                sed -i -E '/<\/VirtualHost>/i \        <LocationMatch "/wp-admin/post.php">\n        SecRuleRemoveById 300013 300014 300015 300016 300017\n\       </LocationMatch> \n' /etc/apache2/sites-enabled>

                sed -i -E '/<\/VirtualHost>/i \        <LocationMatch "/wp-admin/admin-ajax.php">\n       SecRuleRemoveById 300013 300014 300015 300016 300017 \n\       </LocationMatch> \n' /etc/apache2/sites-e>

                service apache2 reload
        fi

fi

echo -e "${GREEN} Installation & configuration succesfully finished.
Script Written By Mentos
Telegram: @freshmentol
Bye!
${NC}
"



