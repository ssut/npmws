# What is NPMWS ?

NPMWS is "NGINX+PHP+MariaDB Web Server Installer".
(NPMWS is not Node.js Package Manager)

# Support OS

Ubuntu (>= 11.04), Debian

# Packages

* nginx web server (stable/development, with config-tweak)
* php 5.4 (the latest version) -> php-fpm(fastcgi process manager)
* mariadb (5.5-stable / 10.0-alpha, better than MySQL)

# PHP Extensions

* intl
* gd
* mcypt
* mhash
* tidy
* pear
* apc (performance)

# Installation

1. Enter this command in terminal.  Please use `sudo` or `log in as root` to run this command.
```bash
	wget -o npmws.sh https://raw.github.com/Previrtu/npmws/master/nginx+php+maria.sh
	chmod +x npmws.sh
	./npmws.sh
```

2. Select nginx/mariadb version.
example)
```bash
	# Select NGINX PPA(Personal Package Archives)
		1) Stable
		2) Development
	Enter: **1 or 2**

	# Select MariaDB version
		1) 5.5 Stable
		2) 10.0 Alpha
	Enter: **1 or 2**
```

3. During installation, Prompt for a password or require some action on the keyboard.


