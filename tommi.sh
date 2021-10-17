#!/bin/bash
#AutoIntaller version 4
#Written by Mentos

#Already CAN:
#LAMP autoinstall
#Autoupdate
#Autoremove and purge
#CSF\ModSec\SSL install
#Wordpress Install
#Phpmyadmin install
#Install singe components

#Must can do:
#LEMP autoinstall
#Autobackup

#PATH variables
ABSPATH=$(readlink -f $0)
ABSDIR=$(dirname $ABSPATH)
SCRIPT=$ABSDIR/scripts
STECK=$ABSDIR/stecks
#Import Main Functions for script
source $SCRIPT/functions.sh

#required_pkgs="sudo bar"

root_check

#Variables for choose in SINGLE user menu
apache="Actions with Apache2"
mysql="Actions with Mysql"
php="Actions with PHP"
update="Update and Upgrade System"
quit="Quit"
wordpress="Install Wordpress"
ssl="Install Lets Encrypt SSL Cert"
modsec="Install ModSecurity with OWASP rules (and some exceptions)"
csf="Install CSF FireWall"

declare -a options=("$update" "$apache" "$mysql" "$php" "$wordpress" "$ssl" "$modsec" "$csf" "$quit")

#Variables for choose in MAIN user menu
lamp="Intall\Remove LAMP"
lemp="Intall\Remove LEMP"
single="Install\Remove SINGLE components"
advanced="Some Awesome Advanced System Upgrades"
declare -a main_options=("$lamp" "$lemp" "$single" "$advanced" "$quit")

function test_menu() {
#kostul, DO NOT TOUCH, select count from 1, for count from 0.
#kostulm safe us from this and for now count from 1 and hide this kostulm
declare -a main_options=("kostulm" "$lamp" "$lemp" "$single" "$advanced" "$quit")
# get length of an array
arraylength=${#main_options[@]}

# use for loop to read all values and indexes
for (( i=1; i<${arraylength}; i++ ));
do
	if [ i != 0 ]; then
 	 echo "$i) ${main_options[$i]}"
	fi
done

}

function single_menu() {
PS3="Enter What You Whish to Do: "
select opt in "${options[@]}"
do
    case $opt in
    	"$update")
		chmod +x $SCRIPT/sys_update.sh
		bash $SCRIPT/sys_update.sh
		banner
		main_menu
		exit
		;;
        "$apache")
        	chmod +x $SCRIPT/apache.sh
        	bash $SCRIPT/apache.sh
           	banner
            	main_menu
		exit
          	;;
        "$mysql")
         	chmod +x $SCRIPT/mysql.sh
        	bash $SCRIPT/mysql.sh
            	banner
            	main_menu
		exit
            	;;
        "$php")
                chmod +x $SCRIPT/php.sh
                bash $SCRIPT/php.sh
                banner
                main_menu
		exit
            	;;
	"$wordpress")
                chmod +x $SCRIPT/wordpress.sh
                sudo bash $SCRIPT/wordpress.sh
	        banner
                main_menu
		exit
		;;
	"$ssl")
		chmod +x $SCRIPT/ssl.sh
                sudo bash $SCRIPT/ssl.sh
                banner
                main_menu
		exit
		;;
        "$modsec")
                chmod +x $SCRIPT/modsec.sh
                sudo bash $SCRIPT/modsec.sh
                banner
                main_menu
		exit
                ;;
	"$csf")
                chmod +x $SCRIPT/csf.sh
                sudo bash $SCRIPT/csf.sh
                banner
                main_menu
		exit
                ;;

        "$quit")
            	break
		exit
            	;;
        *)
        	echo "invalid option $REPLY"
        	;;
    esac
done
}

function main_menu() {
PS3="Enter What You Whish to Do: "
select opt in "${main_options[@]}"
do
    case $opt in
        "$lamp")
                chmod +x $STECK/lamp.sh
                bash $STECK/lamp.sh
                banner
                test_menu
                        ;;

        "$lemp")
                chmod +x $STECK/lemp.sh
                bash $STECK/lemp.sh
                banner
                test_menu
                        ;;

	"$single")
		single_menu
		banner
		test_menu
		;;
        "$advanced")
                chmod +x $SCRIPT/advanced.sh
		bash $SCRIPT/advanced.sh
		banner
		test_menu
                ;;
	"$quit")
		break
		;;
        *)
                echo "invalid option $REPLY"
                ;;
    esac
done

}

main_menu
