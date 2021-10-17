#!/bin/bash
#This script autoinstall apache2 
#
#

#Check if Script run under root
if [ "$USER" != "root" ]; then
    echo "Permission Denied"
    echo "You need to change user to root"
	exit
fi

#Options
instala2="Install Apache2 Latest Version"
removea2="Remove Apache2 and Dependencies"
purgea2="Purge Apache2 (remove all, include configs)"
quit="Quit now!"
options=("$instala2" "$removea2" "$purgea2" "$quit")

#Actions
function apache_install(){
apt-get -qq -y -o Dpkg::Use-Pty=0 install apache2 | bar

systemctl enable apache2
systemctl start apache2
systemctl status apache2	
echo -e "\n\033[32m Apache2 Installed \033[0m"	
}

function apache_autoremove(){
	apt-get -q -y -o Dpkg::Use-Pty=0 remove apache2 | bar
	echo -e "\n\033[33m Apache2 Removed, config files are stayed \033[0m"	
}

function apache_purge(){
	apt-get -q -y -o Dpkg::Use-Pty=0 remove apache2* | bar
	echo -e "\n\033[33m Apache2 Purged no one survived \033[0m"	
}

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