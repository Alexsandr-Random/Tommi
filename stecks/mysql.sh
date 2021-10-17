#!/bin/bash
#This Script Autoinstall Mysql and do some tricks
#
#
#

#Check if Script run under root
if [ "$USER" != "root" ]; then
    echo "Permission Denied"
    echo "You need to change user to root"
	exit
fi

#Options
install_m="Install Mysql Latest Version"
remove_m="Remove Mysql and Dependencies"
purge_m="Purge Mysql (remove all, include databases)"
quit="Quit now!"
options=("$install_m" "$remove_m" "$purge_m" "$quit")

#Actions
#Credentalies
#IF YOU ALREADY  INSTALLED LAMP STECK
#CHANGE THIS VALUES
#IF THIS FIRST INSTALL
#DO NOT TOUCH THIS!
#USER WILL BE AUTO DELETE  HIMSELF

function super_u_create(){
echo "Do You Want to create user and database for your purposes?"
read -p "Enter Y or yes to continue, enter whatever to skip: " answer1
if [[ "$answer1" == [yY] || "$answer1" == [yY][eE][sS] ]]; then
read -p "Enter USERNAME for MYSQL USER: " user
read -p "Enter PASSWORD for MYSQL USER: " password
echo "Creating $user with $passwrod ............."
sleep 1
read -p "Enter DATABASE NAME: " database
echo "Creating $database and grant all priveligies to $user ............." 
#user="tommi"
#password="SeCuRePasS!" 

sudo mysql -e "CREATE USER '$user'@'localhost' IDENTIFIED WITH mysql_native_password;"
sudo mysql -e "ALTER USER '$user'@'localhost' IDENTIFIED BY '$password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO '$user'@'localhost' WITH GRANT OPTION;"

#echo "USE mysql;"
#echo "CREATE USER 'tommi'@'localhost' IDENTIFIED WITH mysql_native_password;"
#echo "ALTER USER 'tommi'@'localhost' IDENTIFIED BY 'SeCuRePasS!';"
#echo "GRANT ALL PRIVILEGES ON *.* TO 'tommi'@'localhost' WITH GRANT OPTION;"
#echo "quit;"
}  


function mysql_install(){
apt -qq -y install mysql-server mysql-common | bar
echo -e "\n Configuring MySQL............ "
sleep 2
mysql_secure_installation
sleep 2
systemctl enable mysql
systemctl start mysql
systemctl status mysql	
echo -e "\n\033[32m Mysql Installed \033[0m"	
}

function mysql_autoremove(){
	apt-get -q -y -o Dpkg::Use-Pty=0 remove mysql-server | bar
	apt -qq -y autoremove && apt autoclean | bar
	echo -e "\n\033[33m Mysql Removed, config files and databases are stayed \033[0m"	
}

function mysql_purge(){
	apt-get -q -y -o Dpkg::Use-Pty=0 remove mysql-server* | bar
	echo -e "\n Removing MySQL Dependensies............ "
	apt -qq -y autoremove && apt autoclean | bar
	echo -e "\n Removing MySQL Data............ "
	rm -rf  /var/lib/mysql /var/log/mysql* /var/log/upstart/mysql.log* /var/run/mysqld 2> /dev/null  | bar
	#/etc/mysql
	deluser --remove-home mysql 2> /dev/null
	delgroup mysql 2> /dev/null
	echo -e "\n\033[33m Mysql Purged no one survived \033[0m"	
}

#User Interactive Menu
function menu() {
PS3="Enter What You Whish to Do: "
select opt in "${options[@]}"
do
    case $opt in
    
		"$install_m")
				mysql_install
				exit
				;;
		"$remove_m")
				mysql_autoremove
				exit
				;;
		"$purge_m")
				mysql_purge
				exit
				;;
		"$quit")
				echo -e "\nOkey, Bye!"
				break
				;;
		*)
				echo -e "\n\033[33m Invalid option $REPLY \033[0m"
				;;
    esac
done
}

menu














