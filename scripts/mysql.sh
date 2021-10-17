#!/bin/bash
#This Script Autoinstall Mysql and do some tricks
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
install_m="Install Mysql Latest Version"
remove_m="Remove Mysql and Dependencies"
purge_m="Purge Mysql (remove all, include databases)"
quit="Quit now!"
options=("$install_m" "$remove_m" "$purge_m" "$quit")
#Actions
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














