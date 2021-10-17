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

#Import Additional Functions
source $ABSDIR/../scripts/additional-func.sh
#Options
cron="Add Daily Update Cron Job"
priv_user="Create Privileged User"
timezone_conf="Configure TimeZone"
quit="Quit"
options=("$cron" "$priv_user" "$timezone_conf" "$quit")
#Actions
#User Interactive Menu
function menu() {
PS3="Enter What You Whish to Do: "
select opt in "${options[@]}"
do
    case $opt in

                "$cron")
                                daily_update_cronjob
                                exit
                                ;;
                "$priv_user")
                                admin_user
                                exit
                                ;;
                "$timezone_conf")
                                config_timezone
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
