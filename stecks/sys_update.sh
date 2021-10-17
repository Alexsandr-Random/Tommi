#!/bin/bash


sys_update(){
	PS3='Do you want to update and upgrade system before we start: '
	options=("Yes, i want to update" "No, skip this")
	select opt in "${options[@]}"
	do
	    case $opt in
	    "Yes, i want to update")
	    	apt update && apt upgrade -yq | bar
			exit;;
	    *)
	    	echo "Goodbye $USER!"
			exit;;
		esac
	done 
	}

#Check if Script run under root
if [ "$USER" != "root" ]; then
    echo "Permission Denied"
    echo "You need to change user to root"
	exit
else 
	sys_update
fi
