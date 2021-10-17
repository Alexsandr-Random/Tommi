#!/bin/bash
function install_csf(){
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Starting CSF+LFD Installation"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"

        apt -y -q install libwww-perl 2>/dev/null
        cd /usr/src
        wget https://download.configserver.com/csf.tgz
        tar xzf csf.tgz
        cd csf
        sh install.sh
        perl /usr/local/csf/bin/csftest.pl

        systemctl stop firewalld
        systemctl mask firewalld

        echo -e "\n BE AWARE! Do You have NON-STANDART SSH port? (standart is 22 port)"
        read -p "Enter y or yes if YOU DO or you lose connection to your server!, enter whatever to skip: " confirm

        if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
                echo -e "Enter your non-standart port number in csf.conf file in TCP_IN and TCP_OUT options"
                echo  -e "*****************Breaking last steps.............**********************"
                sleep 5
                nano /etc/csf/csf.conf
        fi

        sed -i.backup -E 's/TESTING = "1"/TESTING = "0"/g' /etc/csf/csf.conf

        systemctl restart {csf,lfd}
        systemctl enable {csf,lfd}
}
install_csf
