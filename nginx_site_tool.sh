#!/bin/bash
#######################################################
## NGINX Site-tool for Ubuntu/Debian                 ##
## By. previrtu (previrtu@isdev.kr)                  ##
#######################################################

#cat /etc/nginx/sites-available/default | awk "/^[^#]server_name (.+);/" | sed 's/server_name //g' | sed 's/\t//g' | sed 's/\;//g'

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root :(" 
   exit 1
fi

OS=$(awk '/DISTRIB_ID=/' /etc/*-release | sed 's/DISTRIB_ID=//' | tr '[:upper:]' '[:lower:]')
if [ "$OS" != "ubuntu" ] && [ "$OS" != "debian" ]; then
	echo "this script is only executable from Ubuntu/Debian."
	exit
fi

function printMessage() {
	echo -e "\e[1;37m# $1\033[0m"
}

function select_menu {
	SELECT=""

	echo ""
	printMessage "Select menu: "
	echo "	0) Show nginx web site(s)"
	echo "	1) Add nginx web site"
	echo "	2) Delete nginx web site"
	echo ""	
	echo "	e) Edit nginx web site configuration file with gnu-nano-editor"
	echo "	x) Exit script (or Ctrl+C)"
	echo -n "Enter: "
	read SELECT
	
	echo ""
	echo "---------------------------------------------------------------"
	echo " If required value is missing, the process will be cancelled."
	echo "---------------------------------------------------------------"
	case "$SELECT" in
		0)
			show_web_site_list
			;;
		1)
			add_web_site
			;;
		2)
			delete_web_site
			;;
		e)
			config_editor
			;;
		x)
			exit 1
			;;
	esac

	select_menu
}

function show_web_site_list {
	clear
	printMessage "NGINX Web Site List"
	echo "---------------------------------------------------------------"
	printf "%20s | %s\n" "Primary Domain" "Option"
	echo "---------------------------------------------------------------"
	find /etc/nginx/conf.d/* | while read file
	do
		filename=`echo $file | sed "s/\/etc\/nginx\/conf.d\///g"`
		slave_domain=`cat "$file" | awk "/server_name (.+);/" | sed 's/server_name //g' | sed 's/\t//g' | sed 's/\;//g'`
		port=`cat "$file" | awk "/listen (.+);/" | sed "s/listen //g" | sed "s/\t//g" | sed "s/\;//g"`
		printf "%20s | %s\n" "$filename" "DOMAIN={$slave_domain}, PORT={$port}"
	done
	echo "---------------------------------------------------------------"
	return
}

function add_web_site {
	clear
	PRIMARY_DOMAIN=""
	SLAVE_DOMAIN=""
	LISTEN_PORT=""
	DIRECTORY=""
	USE_SSL="0"
	SSL_CRT=""
	SSL_KEY=""
	
	printMessage "Enter primary domain (example: www.previrtu.com)"
	echo -n "Enter: "
	read PRIMARY_DOMAIN

	if [ "$PRIMARY_DOMAIN" == "" ]; then
		return
	fi
	
	if [ -f "/etc/nginx/conf.d/$PRIMARY_DOMAIN" ]; then
		printMessage "Web site($PRIMARY_DOMAIN) is already exist."
		return
	fi
	
	printMessage "Enter slave domains (example: previrtu.com direct.previrtu.com .., delimiter: space)"
	echo -n "Enter: "
	read SLAVE_DOMAIN

	if [ "$SLAVE_DOMAIN" != "" ]; then
		$SLAVE_DOMAIN=" $SLAVE_DOMAIN"
	fi
	
	printMessage "Enter port (default: 80, example: 80 8080 8888 .., delimiter: space)"
	echo -n "Enter: "
	read LISTEN_PORT
	
	PORT_CHAR=`echo "$LISTEN_PORT" | awk "/[a-zA-Z_-]+/"`
	if [ "$PORT_CHAR" != "" ]; then
		printMessage "Port error($PORT_CHAR)."
	elif [ "$LISTEN_PORT" == "" ]; then
		LISTEN_PORT="80"
	fi

	printMessage "Enter directory path (example: /usr/share/nginx/html)"
	echo -n "Enter: "
	read DIRECTORY
		
	if [ ! -d "$DIRECTORY" ] || [ "$DIRECTORY" == "" ]; then
		printMessage "Invalid directory path($DIRECTORY)"
		return
	fi
	
	printMessage "If you want to use SSL Certificate, enter ssl crt file. (example: /usr/share/nginx/ssl.crt)"
	echo -n "Enter: "
	read SSL_CRT
	
	if [ "$SSL_CRT" != "" ] && [ -f "$SSL_CRT" ]; then
		printMessage "Enter ssl key file. (example: /usr/share/nginx/ssl.key)"
		echo -n "Enter: "
		read SSL_KEY
		if [ "$SSL_KEY" != "" ] && [ -f "$SSL_KEY" ]; then
			USE_SSL="1"
		else
			printMessage "Invalid ssl key file. Cancelled."
			USE_SSL="0"
		fi
	fi
	
	cat <<-site-config > /etc/nginx/conf.d/$PRIMARY_DOMAIN
		server {
			listen $LISTEN_PORT;
			server_name $PRIMARY_DOMAIN$SLAVE_DOMAIN;
			root $DIRECTORY;
			index index.php index.html index.htm;
		}
	site-config

	if [ "$USE_SSL" == "1" ]; then
		cat <<-site-config > /etc/nginx/conf.d/$PRIMARY_DOMAIN
			server {
				listen 443;
				server_name $PRIMARY_DOMAIN$SLAVE_DOMAIN;
				root $DIRECTORY;
				index index.php index.html index.htm;
				
				ssl_certificate $SSL_CRT;
				ssl_certificate_key $SSL_KEY;
				ssl_ciphers ALL:!aNULL:!ADH:!eNULL:!LOW:!EXP:RC4+RSA:+HIGH:+MEDIUM;
				ssl_protocols SSLv3 TLSv1;
			}
		site-config
	fi
	
	printMessage "Added."
}

function delete_web_site {
	show_web_site_list
	printMessage "DELETE) Enter primary domain to remove site configuration."
	echo -n "Enter: "
	read DOMAIN

	if [ "$DOMAIN" == "" ]; then
		return
	fi
	
	if [ ! -f "/etc/nginx/conf.d/$DOMAIN" ]; then
		clear
		printMessage "Domain not exist."
		delete_web_site
		return
	elif [ -f "/etc/nginx/conf.d/$DOMAIN" ]; then
		rm -f "/etc/nginx/conf.d/$DOMAIN"
		clear
		printMessage "\"$DOMAIN\" Deleted."
		delete_web_site
	fi
}

function config_editor {
	show_web_site_list
	printMessage "EDIT) Enter primary domain to edit site configuration file."
	echo -n "Enter: "
	read DOMAIN

	if [ "$DOMAIN" == "" ]; then
		return
	fi
	
	if [ ! -f "/etc/nginx/conf.d/$DOMAIN" ]; then
		clear
		printMessage "Domain not exist."
		config_editor
		return
	elif [ -f "/etc/nginx/conf.d/$DOMAIN" ]; then
		nano "/etc/nginx/conf.d/$DOMAIN"
		clear
		delete_web_site
	fi
}

clear
echo "---------------------------------------------------------------"
echo -e "# Welcome to \033[1mNGINX Site-tool\033[0m for Ubuntu/Debian!"
echo "---------------------------------------------------------------"
select_menu
