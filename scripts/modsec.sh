#!/bin/bash
#
#
# Install ModSecurity
function install_modsecurity(){
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

         sed -i.backup -E '/DirectoryIndex index.php/a \   <\/IfModule> ' /etc/apache2/conf-enabled/phpmyadmin.conf
         sed -i.backup -E '/DirectoryIndex index.php/a  \      SecRuleEngine Off  ' /etc/apache2/conf-enabled/phpmyadmin.conf
         sed -i.backup -E '/DirectoryIndex index.php/a  \   <IfModule security2_module>   ' /etc/apache2/conf-enabled/phpmyadmin.conf
         service apache2 reload
   fi

}
install_modsecurity
