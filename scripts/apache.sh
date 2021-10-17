#!/bin/bash
#This script autoinstall apache2 
#
#
#PATH variables
ABSPATH=$(readlink -f $0)
ABSDIR=$(dirname $ABSPATH)
SCRIPT=$ABSDIR/scripts
STECK=$ABSDIR/stecks

#Import Main Functions
source $ABSDIR/../scripts/functions.sh

root_check

#Options
instala2="Install Apache2 Latest Version"
removea2="Remove Apache2 and Dependencies"
purgea2="Purge Apache2 (remove all, include configs)"
quit="Quit now!"
options=("$instala2" "$removea2" "$purgea2" "$quit")

#User Interactive Menu
function menu() {
PS3="Enter What You Whish to Do: "
select opt in "${options[@]}"
do
    case $opt in
		"$instala2")
				apache_install
				exit
				;;
		"$removea2")
				apache_autoremove
				exit
				;;
		"$purgea2")
				apache_purge
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
