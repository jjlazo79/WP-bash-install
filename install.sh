#!/bin/bash 
clear   
bold=`tput bold`
normal=`tput sgr0`

red='\033[1;31m'
green='\033[1;32m'        
blue='\033[1;34m'        
NC='\033[0m' # No Color   
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
DOMAIN_DIR=$( basename $(dirname $PWD) )
ADMIN_USER=jjlazo79
ADMIN_EMAIL=jjlazo79@gmail.com
cat << EOF
+--------------------------------------------+
|                                            |
|       Wordpress CLI Installer 1.02         |
|                                            |
|  https://github.com/jjlazo79/WP-bash-install  |
|                                            |
|    Step-by-step semi-automatic install     |
|    latest WP with some useful plugins      |
|                                            |
|         wp-cli must be installed           |
|  see http://wp-cli.org/ for instructions   |
|                                            |
+--------------------------------------------+
EOF

##if test -f "index.php"; then echo "Dir not empty"; exit 1; fi

printf "\n${bold}Select locale${normal} [1 - RU, 2 - en]: "

read language

case $language in
	1)
	locale="es_ES"
	;;
	2)
	locale="en_US" 
	;;
	*)
	#printf "\n${red}Locale not selected.${NC} Bye \n\n"; exit 1;
	locale="es_ES"
esac
printf "\n${bold}Downloading${normal}...\n" 

wp core download --locale="$locale" || { 
##printf "\nDo you want to continue?\n"; 

  read -r -p "${bold}Do you want to continue? ${normal}[y/N] " response
  response=${response,,}    # tolower
  if ! [[ $response =~ ^(yes|y)$ ]]  
  then 
    printf "\n${bold}Aborting...${normal} Bye\n\n"
    exit 1;
  fi

}

if test -f "wp-config.php"; 
then 
  read -r -p "${bold}Seems that wp-config.php already created. What we gonna do?${normal} [${bold}o${normal}verwrite/${bold}U${normal}SE/${bold}a${normal}bort] " response
    response=${response,,}    # tolower
    if [[ $response =~ ^(overwrite|o)$ ]]  
    then 
      printf "\n${bold}Backuping existed config to wp-config.php.bak ${normal}\n\n"
      mv wp-config.php wp-config.php.bak
    fi
    if [[ $response =~ ^(abort|a)$ ]]  
    then 
      printf "\n${bold}Aborting...${normal} Bye\n\n"
      exit 1;        
    fi 
else
  printf  "\nSeems that wp-config.php does not exist"
  printf  "\n${bold}Lets create it${normal}"
  printf "\nEnter dbname: "
  read -e dbname

  printf "\nEnter dbuser: "
  read -e dbuser

  printf "\nEnter dbpass: "
  read -e dbpass
  printf  "\n${bold}Creating wp-config.php...${normal}\n"

  wp core config --dbname="$dbname" --dbuser="$dbuser" --dbpass="$dbpass" || {
  printf  "\n${red}Error${NC}: Seems that db connections cannot estabished. Please check db properties and try again. Bye\n\n"; exit 1;
  }
fi

if [[ $response =~ ^(use|u|'')$ ]]   
then  
  printf  "\n${bold}Using existing wp_config.php with follow parameters${normal}\n" 
  grep DB_NAME wp-config.php
  grep DB_USER wp-config.php
  grep DB_PASS wp-config.php
fi  

printf  "\n${bold}Now enter site parameters${normal}"

printf "\nEnter hostname without http and slashes: ($DOMAIN_DIR) "
read -e domain
if [ -z "$domain" ]; then
    domain=$DOMAIN_DIR
fi

printf "\ndomain set to $domain"

printf "\nEnter title: "
read -e title

printf "\nEnter admin login ($ADMIN_USER): "
read -e login
if [ -z "$login" ]; then
    login=$ADMIN_USER
    printf "\nlogin set to $login"
fi
    

DEFAULT_ADMIN_PASS=$(openssl rand -base64 8)
printf "\nEnter admin pass ($DEFAULT_ADMIN_PASS): "
read -e pass
if [ -z "$pass" ]; then
    pass=$DEFAULT_ADMIN_PASS
fi
printf "\npass set to $pass"

printf "\nEnter admin email ($ADMIN_EMAIL): "
read -e adm_email
if [ -z "$adm_email" ]; then
    adm_email=$ADMIN_EMAIL
    printf "\nemail set to $adm_email"
fi
    

printf  "\n${bold}Installing, please wait...${normal} "
printf "\n"
if ! $(wp core is-installed); then
    wp core install --url=$domain --title="$title" --admin_user="$login" --admin_password="$pass" --admin_email="$adm_email"
fi
printf "\n" 

wp plugin delete akismet
wp plugin delete hello.php

read -r -p "${bold}Do you want install some useful plugins? ${normal}[y/N] " response
response=${response,,}    # tolower
if [[ $response =~ ^(yes|y)$ ]]  
then 
  plugins_array=(
    "contact-form-7" 
    "cyr3lat" 
    "seo-by-rank-math" 
    "w3-total-cache"
    "all-in-one-wp-security-and-firewall"
    );

  for i in "${plugins_array[@]}"
  do
    read -r -p "${bold}Do you want to install $i?${normal} [y/N] " response
    response=${response,,}    # tolower
    if [[ $response =~ ^(yes|y)$ ]]  
    then 
      wp plugin install $i
      # wp plugin activate $i
    fi
  done
fi

printf "\n${green}Done!${NC}\n"
read -r -p  "${bold}Do you wanna delete this installation script?${normal} [y/N] " response
  response=${response,,}    # tolower 
  printf "\n${bold}Bye.${normal}\n\n"
  if [[ $response =~ ^(yes|y)$ ]]  
  then 
    rm $0 
  fi
rm license.txt
rm readme.html
