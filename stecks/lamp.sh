#!/bin/bash
#This script Install and Remove LAMP Steck Automaticly
#
#
#PATH variables
ABSPATH=$(readlink -f $0)
ABSDIR=$(dirname $ABSPATH)
SCRIPT=$ABSDIR/../scripts
STECK=$ABSDIR/stecks

#Import Main Functions
source $ABSDIR/../scripts/functions.sh
source $ABSDIR/../scripts/security.sh
root_check

#Actions
#LAMP INSTALL
function lamp_install() {
sys_update
php_install
apache_install
mysql_install
install_modsecurity
set_owasp_rules
}
#LAMP REMOVE
function lamp_remove() {
apache_remove
php_autoremove
mysql_autoremove
phpmyadmin_remove
delete_modsecurity
sys_clean
}
#BE AWARE!!!
#REMOVE AVERYTHING INCLUDE DATABASES AND CONFIG FILES!!!
#LAMP PURGE
function lamp_purge() {
apache_purge
php_purge
mysql_purge
phpmyadmin_remove
delete_modsecurity
sys_clean
}

#Options
install_lamp="Install LAMP Steck (last versions)"
remove_lamp="Remove LAMP Steck and Dependencies (config files and databases are stayed)"
purge_lamp="Purge LAMP (remove all, include databases and config files!)"
quit="Quit now!"
options=("$install_lamp" "$remove_lamp" "$purge_lamp" "$quit")

function menu() {
PS3="Enter What You Whish to Do: "
select opt in "${options[@]}"
do
    case $opt in
        "$install_lamp")
                lamp_install
		echo -e "\nDo You Want to install Wordpress?"
		read -p "Enter y or yes to continue, enter whatever to skip: " confirm

		if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
                chmod +x $SCRIPT/wordpress.sh
		sudo bash $SCRIPT/wordpress.sh
		fi
		exit
                ;;
        "$remove_lamp")
                lamp_remove
		exit
                ;;
        "$purge_lamp")
		echo -e "\n ${YELLOW} Do You Really want to DESTROY EVERYTHING INCLUDE DATABASES AND CONFIGS???! ${NC}"
		read -p "Enter y or yes to continue, enter whatever to skip: " confirm
        	if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
                	lamp_purge
		fi
		exit
		;;
       "$quit")
                echo -e "\n Okey, Bye!"
                break
                ;;
        *)
                echo -e "\n\033[33m Invalid option $REPLY \033[0m"
                ;;
    esac
done
}

menu























