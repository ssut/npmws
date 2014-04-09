# What is NPMWS ?

NPMWS is "NGINX+PHP+MariaDB Web Server Installer".
(NPMWS is not Node.js Package Manager)

# Support OS

Ubuntu, Debian, Linux Mint (LDME/Nadia)

Does not support [end of maintenance ubuntu versions](http://www.ubuntu.com/info/release-end-of-life)

# Packages

* nginx web server - stable/development, with some tasty tweaks :)
* php 5.4(old stable version) or 5.5(the latest version) -> php-fpm(fastcgi process manager)
* mariadb (5.5-stable / 10.0-alpha, better than MySQL)
* phpMyAdmin (the latest version)

# PHP Extensions

* intl
* cURL
* gd
* mcypt
* mhash
* tidy
* sqlite (pdo)
* mysql (pdo)
* mysqli
* xdebug
* pear
* apc (for performance improvement)

# Installation

1. You can install this via the command line with either `curl` or `wget`. (Please use `sudo` or `log in as root` to run this command)
* via `curl`
 `curl https://raw.github.com/Previrtu/npmws/master/npmws.sh`
* via `wget`
 `wget https://raw.github.com/Previrtu/npmws/master/npmws.sh`
* change permission and execute script.
 `chmod +x npmws.sh`
 `./npmws.sh`

2. Select nginx/mariadb version.
```bash
	# Select NGINX PPA(Personal Package Archives)
		1) Stable
		2) Development
	Enter: 

	# Select MariaDB version
		1) 5.5 Stable
		2) 10.0 Alpha
	Enter: 
```

3. During installation, Prompt for a password or require some action on the keyboard.


