#!/bin/bash
#Main Functions for Scripts
#DO NOT TOUCH!
#Colors settings
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

#PATH variables
ABSPATH=$(readlink -f $0)
ABSDIR=$(dirname $ABSPATH)
TEMPLATES=$ABSDIR/../templates
STECK=$ABSDIR/stecks

function banner(){
        banner="
  _______                                   _
 |__   __|                                 (_)
    | |      ___    ________    ________    _
    | |     / _ \  |  _ _   \  |  _   _  \ | |
    | |    | (_) | | | | | | | | | | | | | | |
    |_|     \___/  |_| |_| |_| |_| |_| |_| |_|

  Automated Script for Linux
  Written By Mentos
        "
clear
echo "$banner"
}
#Check for  PreRequired pakages and autoinstall it
function pkg_check() {
required_pkgs="sudo bar software-properties-common"
for pkg in $required_pkgs; do
        pkg_ok=$(dpkg-query -W --showformat='${Status}\n' $pkg|grep "install ok installed")
        echo Checking for $pkg: $pkg_ok
        if [ "" = "$pkg_ok" ]; then
          echo "No $pkg found. Setting up $pkg."
          sudo apt -yq  install $pkg  > /dev/null 2>&1
        fi
done
}
#Check if Script run under root
function root_check(){
if [ "$USER" != "root" ]; then
    echo "Permission Denied"
    echo "You need to change user to root"
        exit
else
        banner
        pkg_check
fi
}
#General System Update
function sys_update(){
        apt update && apt upgrade -yq | bar
        echo "System was updated and upgraded"
}
function sys_clean(){
	apt-get autoclean && apt-get autoremove -yq | bar
	echo "System is Clean!"
}
######################################################MYSQL FUNCTIONS######################################################
#Mysql Install
function mysql_install(){
apt -qq -y install mariadb-server | bar
echo -e "\n Configuring MySQL............ "
sleep 2
systemctl enable mysql
systemctl start mysql
systemctl status mysql
mysql_v=$( mysql -V |grep -Eo 'Ver [0-9]\.[0-9]' )
echo -e "\n\033[32m Mysql $mysql_v Installed \033[0m"
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
        echo -e "$result_mysql" > mysql_credentialies.txt
fi
}   
create_muser_db
function mysql_secure() {
echo -e "\nDo You Want to start mysql SECURE installation?"
read -p "Enter y or yes to continue, enter whatever to skip: " confirm

if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
mysql_secure_installation
fi
}
mysql_secure
echo -e "$result_mysql"
sleep 3
function phpmyadmin_install(){
phpmyadm_status=$(dpkg-query -W -f='${Status}' phpmyadmin 2>/dev/null | grep -i -c "ok installed")
  if [ "$phpmyadm_status" == "" ]  || [ "$phpmyadm_status" != "ok installed" ];then
    echo -e "${YELLOW}Installing phpmyadmin${NC}"
    add-apt-repository ppa:phpmyadmin/ppa
    apt-get update
    apt-get -y -q  -o Dpkg::Use-Pty=0 install phpmyadmin 2>/dev/null
    echo -e "\nDo You Want to create phpmyadmin SUPER USER and login by this user in PHPMYADMIN?"
    read -p "Enter y or yes to continue, enter whatever to skip: " confirm
        if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
                read -p "Please, enter NEW username: " p_user
                sudo mysql -utommi -p$passwd -e "CREATE USER '$p_user'@'localhost' IDENTIFIED WITH mysql_native_password;" 2>/dev/null
                read -p "Please, enter NEW $p_user password: " p_password
                sudo mysql  -utommi -p$passwd  -e "ALTER USER $p_user@localhost IDENTIFIED BY '$p_password';" 2>/dev/null
                sudo mysql  -utommi -p$passwd  -e "GRANT ALL PRIVILEGES ON *.* TO $p_user@localhost WITH GRANT OPTION;" 2>/dev/null
                cat > phpmyadmin.txt <<EOL
***************Your PhpMyAdmin Credentials*****************
PhpMyAdmin User: $p_user         
Password: $p_password
***************Your PhpMyAdmin Credentials*****************
EOL
                echo -e "${GREEN} Your NEW password and user saved in file phpmyadmin.txt ${NC}"
                sleep 2
        fi
    elif [ "$phpmyadm_status" == "ok installed" ];
    then
      echo -e "${GREEN}phpmyadmin is installed!${NC}"
  fi
}

echo -e "\nDo You Want to install phpmyadmin?"
read -p "Enter y or yes to continue, enter whatever to skip: " confirm

if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
 phpmyadmin_install
fi

sudo mysql -uroot -p$root_pass -e "DROP USER tommi@localhost;"
}
function mysql_autoremove(){
        service mysql stop
        apt-get -q -y -o Dpkg::Use-Pty=0 remove mariadb-server* 2>/dev/null | bar
        echo -e "\n\033[33m Mysql Removed, config files and databases are stayed \033[0m"
}
function mysql_purge(){
        service mysql stop
        apt-get -q -y -o Dpkg::Use-Pty=0 remove mariadb-server* | bar
        echo -e "\n Removing MySQL Dependensies............ "
        sys_clean
        echo -e "\n Removing MySQL Data............ "
        rm -rf  /var/lib/mysql /var/log/mysql* /var/log/upstart/mysql.log* /var/run/mysqld 2> /dev/null  | bar
        #/etc/mysql - destroy script in many cases
        deluser --remove-home mysql 2> /dev/null
        delgroup mysql 2> /dev/null
        echo -e "\n\033[33m Mysql Purged no one survived \033[0m"
}
function phpmyadmin_remove(){
apt-get -q -y -o Dpkg::Use-Pty=0 remove phpmyadmin* 2>/dev/null | bar
echo -e "${YELLOW} PhpMyAdmin removed! ${NC}"
}                                                                                                 
##########################################################PHP(fpm) !LEMP! FUNCTIONS###############################################
#PHP install
function php_install(){
pkg_check
#libapache2-mod-php php-mysql
#add-apt-repository ppa:ondrej/php
apt -qq -y install php-fpm  | bar
#MOST IMPORTANT VARIABLE HERE
php_v=$( php -v | grep "PHP" | grep -E -o '[0-9]\.[0-9]' )

echo -e "\n\033[32m PHP Installed, Current Version is: $php_v \033[0m"
}
function php_autoremove(){
    apt-get -q -y -o Dpkg::Use-Pty=0 remove php-fpm$php_v 2>/dev/null | bar
    apt -qq -y autoremove && apt autoclean | bar
    echo -e "\n\033[33m PHP$php_v Removed \033[0m"
}
function php_purge(){
    apt-get -q -y -o Dpkg::Use-Pty=0 remove php-fpm* | bar
    echo -e "\n Removing php Dependensies............ "
    apt -qq -y autoremove && apt autoclean | bar
    echo -e "\n\033[33m PHP$php_v Purged no one survived \033[0m"
}
##########################################################PHP FUNCTIONS###############################################
##########################################################NGINX FUNCTIONS############################################### 
#Nginx install
function nginx_install(){
apt-get -qq -y -o Dpkg::Use-Pty=0 install nginx | bar

systemctl enable nginx
systemctl start nginx
systemctl status nginx

echo -e "\n\033[32m nginx Installed \033[0m"
echo -e "\nDo You Want to create test index.php file to check processing php code?"
read -p "Enter y or yes to continue, enter whatever to skip: " confirm

if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
cp $TEMPLATES/index.php /var/www/html/test-php.php
rm -f index.html
cp $TEMPLATES/index.html /var/www/html/index.html
fi
}
#Nginx Remove
function nginx_remove(){
        service nginx stop
        apt-get -q -y -o Dpkg::Use-Pty=0 remove nginx* 2>/dev/null
        echo -e "\n\033[33m nginx Purged no one survived \033[0m"
}
#Nginx Purge
function nginx_purge(){
        service nginx stop
        apt-get -q -y -o Dpkg::Use-Pty=0 remove nginx* 2>/dev/null
        echo -e "\n\033[33m nginx Purged no one survived \033[0m"
        rm -rf /etc/nginx/sites-enabled/*
}
function say_bye(){
        echo -e "{$GREEN}This script Written by MentoS\n Say thanks: @freshmentol \n Enjoy!{$NC}"

}

##########################################################NGINX FUNCTIONS###############################################
