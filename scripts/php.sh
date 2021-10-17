#!/bin/bash
#This Script Autoinstall php and do some tricks
#
#
#
#PATH variables
ABSPATH=$(readlink -f $0)
ABSDIR=$(dirname $ABSPATH)
SCRIPT=$ABSDIR/scripts
STECK=$ABSDIR/stecks

#Import Main Functions
source $ABSDIR/../scripts/functions.sh

#Options
install_p="Install php Latest Version"
remove_p="Remove php and Dependencies"
purge_p="Purge php (remove all)"
quit="Quit now!"
options=("$install_p" "$remove_p" "$purge_p" "$quit")

#User Interactive Menu
function menu() {
PS3="Enter What You Whish to Do: "
select opt in "${options[@]}"
do
    case $opt in
        "$install_p")
                php_install
                exit
                ;;
        "$remove_p")
                php_autoremove
                exit
                ;;
        "$purge_p")
                php_purge
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
