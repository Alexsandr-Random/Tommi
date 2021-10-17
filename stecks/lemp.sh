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
source $ABSDIR/../scripts/functions-lemp.sh
source $ABSDIR/../scripts/security.sh
root_check
#Actions
#LEMP INSTALL
function lemp_install() {
sys_update
nginx_install
mysql_install
php_install
#install_modsecurity
#set_owasp_rules #csf + owasp rules install

}
#LEMP REMOVE
function lemp_remove() {
nginx_remove
php_autoremove
mysql_autoremove
phpmyadmin_remove
#delete_modsecurity
sys_clean
}
#BE AWARE!!!
#REMOVE AVERYTHING INCLUDE DATABASES AND CONFIG FILES!!!
#LEMP PURGE
function lemp_purge() {
nginx_purge
php_purge
mysql_purge
phpmyadmin_remove
#delete_modsecurity
sys_clean
}

#Options
install_lemp="Install LEMP Steck (last versions)"
remove_lemp="Remove LEMP Steck and Dependencies (config files and databases are stayed)"
purge_lemp="Purge LEMP (remove all, include databases and config files!)"
quit="Quit now!"
options=("$install_lemp" "$remove_lemp" "$purge_lemp" "$quit")

function menu() {
PS3="Enter What You Whish to Do: "
select opt in "${options[@]}"
do
    case $opt in
        "$install_lemp")
                lemp_install
                echo -e "\nDo You Want to install Wordpress?"
                read -p "Enter y or yes to continue, enter whatever to skip: " confirm
                if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
                chmod +x $SCRIPT/wordpress-lemp.sh
                sudo bash $SCRIPT/wordpress-lemp.sh
                fi
                exit
                ;;
        "$remove_lemp")
                lemp_remove
                exit
                ;;
        "$purge_lemp")
                echo -e "\n ${YELLOW} Do You Really want to DESTROY EVERYTHING INCLUDE DATABASES AND CONFIGS???! ${NC}"
                read -p "Enter y or yes to continue, enter whatever to skip: " confirm
                if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
                        lemp_purge
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
