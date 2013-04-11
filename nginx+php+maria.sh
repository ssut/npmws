#!/bin/bash
#######################################################
## NGINX + PHP + MariaDB Installer for Ubuntu/Debian ##
## By. previrtu (previrtu@isdev.kr)                  ##
#######################################################
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root :(" 
   exit 1
fi

OS=$(awk '/DISTRIB_ID=/' /etc/*-release | sed 's/DISTRIB_ID=//' | tr '[:upper:]' '[:lower:]')
NGINX_PPA=0
MARIADB_VER="5.5"
if [ "$OS" != "ubuntu" ] && [ "$OS" != "debian" ]; then
	echo "this script is only executable from Ubuntu/Debian."
	exit
fi

function apt_cache_update {
	echo "# Updating APT(Advanced Packaging Tool) cache"
	./test.sh > /dev/null
	apt-get update > /dev/null
}

function select_nginx {
		echo ""
		echo "# Select NGINX PPA(Personal Package Archives)"
		echo "	1) Stable"
		echo "	2) Development"
		echo -n "Enter: "
		read NGINX_PPA
		if [ "$NGINX_PPA" != 1 ] && [ "$NGINX_PPA" != 2 ]; then
			select_nginx
		fi
}

function select_mariadb {
	echo ""
	echo "# Select MariaDB version"
	echo "	1) 5.5 Stable"
	echo "	2) 10.0 Alpha"
	echo -n "Enter: "
	read MARIADB_SELECT
	if [ "$MARIADB_SELECT" != 1 ] && [ "$MARIADB_SELECT" != 2 ]; then
		select_mariadb
	elif [ "$MARIADB_SELECT" == 1 ]; then
		MARIADB_VER="5.5"
	elif [ "$MARIADB_SELECT" == 2 ]; then
		MARIADB_VER="10.0"
	fi
}

function func_install {
	echo -n "Are you sure want to continue? (y/n): "
	read YN 
	YN=`echo $YN | tr "[:lower:]" "[:upper:]"`
	if [ "$YN" != "Y" ] && [ "$YN" != "N" ]; then
		func_install
	elif [ "$YN" == "N" ]; then
		exit
	fi
}

function check_py_apt {
	if [ -f /usr/bin/add-apt-repository ]; then
		echo "- add-apt-repository: exist"
	else
		echo "- add-apt-repository: not exist"
		echo "# INSTALLING PYTHON-SOFTWARE-PROPERTIES"
		apt-get install python-software-properties -y
	fi
}

function install_nginx {
	echo "# INSTALLING NGINX"
	
	NGINX_LW="stable"
	if [ "$NGINX_PPA" == 2 ]; then
		NGINX_LW="development"
	fi
	
	add-apt-repository ppa:nginx/$NGINX_LW -y
	apt_cache_update
	apt-get install nginx -y
}

function install_php5 {
	echo "# INSTALLING PHP5"
	
	add-apt-repository ppa:ondrej/php5 -y
	apt_cache_update
	apt-get install build-essential gcc g++ -y
	apt-get install libcurl3-openssl-dev -y
	apt-get install libpcre3 -y
	apt-get install libpcre3-dev -y	
	apt-get install php5-common php5-cgi php5-cli php5-fpm php5-gd php5-cli php5-mcrypt php5-tidy -y
	apt-get install php5-intl php5-dev -y
	apt-get install php-pear -y

	echo "# Please press return key."
	sleep 1
	pecl install apc
	echo "extension=apc.so" >> /etc/php5/mods-available/apc.ini
	ln -s /etc/php5/mods-available/apc.ini /etc/php5/conf.d/apc.ini
}

function install_mariadb {
	echo "# INSTALLING MariaDB"
	
	if [ "$MARIADB_VER" == "5.5" ]; then
		apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
		add-apt-repository 'deb http://ftp.kaist.ac.kr/mariadb/repo/5.5/ubuntu precise main' -y
	elif [ "$MARIADB_VER" == "10.0" ]; then
		apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
		add-apt-repository 'deb http://ftp.kaist.ac.kr/mariadb/repo/10.0/ubuntu precise main' -y
	fi
	
	apt_cache_update
	apt-get install mariadb-server -y

	echo "# INSTALLING PHP5-MySQL (Extension for connect to database server)"
	apt-get install php5-mysql -y
}

function setting_nginx {
	echo "# SETTING NGINX"
	
	echo "location ~ \.php\$ {" >> /etc/nginx/php
	echo "	fastcgi_pass unix:/var/run/php5-fpm.sock;" >> /etc/nginx/php
	echo "	fastcgi_index index.php;" >> /etc/nginx/php
	echo "	fastcgi_split_path_info ^(.+\.php)(/.+)\$;" >> /etc/nginx/php
	echo "	fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;" >> /etc/nginx/php
	echo "	include /etc/nginx/fastcgi_params;" >> /etc/nginx/php
	echo "}" >> /etc/nginx/php
	
	rm -f /etc/nginx/sites-available/default
	echo "server {" >> /etc/nginx/sites-available/default
	echo "	listen 80 default_server;" >> /etc/nginx/sites-available/default
	echo "	" >> /etc/nginx/sites-available/default
	echo "	root /usr/share/nginx/html;" >> /etc/nginx/sites-available/default
	echo "	index index.php index.html index.htm;" >> /etc/nginx/sites-available/default
	echo "	" >> /etc/nginx/sites-available/default
	echo "	server_name localhost 127.0.0.1;" >> /etc/nginx/sites-available/default
	echo "	" >> /etc/nginx/sites-available/default
	echo "	include php;" >> /etc/nginx/sites-available/default
	echo "}" >> /etc/nginx/sites-available/default

	mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
	echo "user www-data;" >> /etc/nginx/nginx.conf
	echo "worker_processes 4;" >> /etc/nginx/nginx.conf
	echo "#pid /run/nginx.pid;" >> /etc/nginx/nginx.conf
	echo "" >> /etc/nginx/nginx.conf
	echo "events {" >> /etc/nginx/nginx.conf
	echo "	worker_connections 1024;" >> /etc/nginx/nginx.conf
	echo "	use epoll;" >> /etc/nginx/nginx.conf
	echo "	multi_accept on;" >> /etc/nginx/nginx.conf
	echo "" >> /etc/nginx/nginx.conf
	echo "http {" >> /etc/nginx/nginx.conf
	echo "	sendfile on;" >> /etc/nginx/nginx.conf
	echo "	tcp_nopush on;" >> /etc/nginx/nginx.conf
	echo "	tcp_nodelay on;" >> /etc/nginx/nginx.conf
	echo "	" >> /etc/nginx/nginx.conf
	echo "	keepalive_timeout 5;" >> /etc/nginx/nginx.conf
	echo "	types_hash_max_size 2048;" >> /etc/nginx/nginx.conf
	echo "	server_tokens off;" >> /etc/nginx/nginx.conf
	echo "	" >> /etc/nginx/nginx.conf
	echo "	include /etc/nginx/mime.types;" >> /etc/nginx/nginx.conf
	echo "	default_type application/octet-stream;" >> /etc/nginx/nginx.conf
	echo "	" >> /etc/nginx/nginx.conf
	echo "	access_log /var/log/nginx/access.log;" >> /etc/nginx/nginx.conf
	echo "	error_log /var/log/nginx.error.log;" >> /etc/nginx/nginx.conf
	echo "	" >> /etc/nginx/nginx.conf
	echo "	gzip on;" >> /etc/nginx/nginx.conf
	echo "	gzip_disable \"msie6\";" >> /etc/nginx/nginx.conf
	echo "	" >> /etc/nginx/nginx.conf
	echo "	include /etc/nginx/conf.d/*.conf;" >> /etc/nginx/nginx.conf
	echo "	include /etc/nginx/sites-enabled/*;" >> /etc/nginx/nginx.conf
	echo "}" >> /etc/nginx/nginx.conf
	
	chmod 755 /etc/nginx/nginx.conf
	chmod 755 /etc/nginx/sites-available/default

	chmod -R 777 /usr/share/nginx/html/*
	chmod	-R 755 /usr/share/nginx/html
}

clear
echo "---------------------------------------------------------------"
echo "# Welcome to NGINX+PHP+MariaDB Installer for Ubuntu/Debian!"
echo "# Script version 1.0"
echo "---------------------------------------------------------------"
select_nginx
select_mariadb

echo ""
echo "---------------------------------------------------------------"
echo "This script will be install:"
NGX_COMMENT="NGINX"
[ "$NGINX_PPA" == 1 ] && NGX_VER="Stable" || NGX_VER="Development"
echo "	$NGX_COMMENT $NGX_VER"
echo "	PHP stable (The latest version) + PHP Extensions"
echo "	MariaDB $MARIADB_VER"
echo "---------------------------------------------------------------"
echo ""
func_install
check_py_apt
install_nginx
install_php5
install_mariadb

echo "# Stopping Nginx service"
service nginx stop

echo "# Configuring nginx"
setting_nginx

echo "# Starting nginx/php5-fpm/mariadb service"
service nginx start
service php5-fpm restart
service mysql restart

echo ""
clear
echo "---------------------------------------------------------------"
echo "# Installed NGINX+PHP+MariaDB."
echo "---------------------------------------------------------------"
echo "* NGINX: service nginx {start|stop|restart|reload|status}"
echo "	/etc/nginx/"
echo "* PHP: service php5-fpm {start|stop|restart|status}"
echo "	/etc/php5/php5-fpm/"
echo "* MariaDB: service mysql {start|stop|restat|status}"
echo "	/etc/mysql/"
echo "---------------------------------------------------------------"
echo "  NGINX+PHP+MariaDB by Previrtu(previrtu@isdev.kr)"
echo "---------------------------------------------------------------"

