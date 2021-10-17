#!/bin/bash
#
#
# Install ModSecurity
function install_modsecurity(){  
echo "Do You Want to install ModSecurity?"
read -p "Enter y or yes to continue, enter whatever to skip: " confirm
if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then       
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Installing ModSecurity"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    apt -y -q install libxml2 libxml2-dev libxml2-utils
    apt -y -q install libaprutil1 libaprutil1-dev
    apt -y -q install libapache2-mod-security2 modsecurity-crs
    a2enmod security2 
    service apache2 reload
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Setting UP OWASP ModSecurity Core Rule Set (CRS3)"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"

    mv /etc/modsecurity/modsecurity.conf{-recommended,}
    sed -i.backup -E 's/SecRuleEngine\ DetectionOnly/SecRuleEngine\ On/g' /etc/modsecurity/modsecurity.conf
    sed -i.backup -E '/<\/IfModule>/i IncludeOptional \"/usr/share/modsecurity-crs/*.conf"\
IncludeOptional \"/usr/share/modsecurity-crs/activated_rules/*.conf"\ ' /etc/apache2/mods-enabled/security2.conf
    echo 'SecServerSignature "The Brick v2.1.8"' >> /usr/share/modsecurity-crs/modsecurity_crs_10_setup.conf
    echo 'Header set X-Powered-By "Guy Ritchie v.2.0.00"' >> /usr/share/modsecurity-crs/modsecurity_crs_10_setup.conf
    echo 'Header set X-Designed-By "Boris The Blade, or Boris The Bullet-Dodger"' >> /usr/share/modsecurity-crs/modsecurity_crs_10_setup.conf
    a2enmod headers
    service apache2 reload

    phpadmin_check=$(dpkg-query -W --showformat='${Status}\n' phpmyadmin)
    if [ "$phpadmin_check" == "install ok installed" ]; then
    
   	 echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    	 echo -e "\e[93m[+]\e[00m Setting UP PHPMYADMIN ModSec Rules...."
   	 echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
	
	 sed -i.backup -E '/DirectoryIndex index.php/a \   <\/IfModule> \      SecRuleEngine Off   \   <IfModule security2_module>   ' /etc/apache2/conf-enabled/phpmyadmin.conf
         #sed -i -E '/DirectoryIndex index.php/a  \      SecRuleEngine Off  ' /etc/apache2/conf-enabled/phpmyadmin.conf 
         #sed -i -E '/DirectoryIndex index.php/a  \   <IfModule security2_module>   ' /etc/apache2/conf-enabled/phpmyadmin.conf
	 service apache2 reload
   fi
fi

}

function delete_modsecurity(){
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Removing ModSecurity"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    a2dismod security2
    sudo apt-get -y -q purge modsecurity-crs libapache2-mod-security2 2>/dev/null
    apt -y -q autoremove && apt-get clean
    rm -rf /etc/modsecurity/ /usr/share/modsecurity-crs/ /etc/apache2/mods-enabled/security2.conf  2>/dev/null
    fck_you=$(find / modsecurity | grep -i modsecurity)
    rm -rf $fck_you  2>/dev/null
    service apache2 reload
}

function install_csf(){
echo "Do You Want to install CSF Firewall?"
read -p "Enter y or yes to continue, enter whatever to skip: " confirm
if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
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

        usr_ip=$(echo $SSH_CLIENT | awk '{print $1}')
        usr_port=$(echo $SSH_CLIENT | awk '{print $3}')
	csf -a $usr_ip 2>/dev/null
        echo "$usr_ip" >> /etc/csf/csf.ignore

	echo -e "\n BE AWARE! Do You have NON-STANDART SSH port? (standart is 22 port)"
	read -p "Enter y or yes if YOU DO or you lose connection to your server!, enter whatever to skip:  " confirm

	if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
	echo "Adding your non-standart $usr_port port in csf....."
	sed -i.backup -e "s|TCP_IN = \"20,21|TCP_IN = \"20,21,$usr_port|g" /etc/csf/csf.conf
	sed -i.backup -e "s|TCP_OUT = \"20,21|TCP_OUT = \"20,21,$usr_port|g" /etc/csf/csf.conf
	sleep 1

	fi

        sed -i.backup -E 's/TESTING = "1"/TESTING = "0"/g' /etc/csf/csf.conf

	systemctl restart {csf,lfd}
	systemctl enable {csf,lfd}
	csf -p
fi
}

install_csf
