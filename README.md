# What is NPMWS ?

NPMWS is "NGINX+PHP+MariaDB Web Server Installer".
(NPMWS is not Node.js Package Manager)

# Support OS

Ubuntu (>= 11.04), Debian

# Packages

* nginx web server (stable/development, with config-tweak)
* php 5.4 (the latest version) -> php-fpm(fastcgi process manager)
* mariadb (5.5-stable / 10.0-alpha, better than MySQL)
* phpMyAdmin (the latest version)

# PHP Extensions

* intl
* cURL
* gd
* mcypt
* mhash
* tidy
* pear
* apc (performance)

# Installation

1. You can install this via the command line with either `curl` or `wget`. (Please use `sudo` or `log in as root` to run this command)
via `curl`
`curl -L https://raw.github.com/Previrtu/npmws/master/nginx+php+maria.sh | sh`
via `wget`
`wget --no-check-certificate https://raw.github.com/Previrtu/npmws/master/nginx+php+maria.sh -O - | sh`

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


