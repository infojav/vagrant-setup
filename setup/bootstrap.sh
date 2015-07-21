#!/usr/bin/env bash
#

# Installation Options ##############################################

nginx=true
curl=true
git=true 
redis=true
mysql=true
mongodb=true
memcached=true
php5=true
java=true 
android_sdk=true
webdriver=true
nodejs=true
imagemagick=true 
postgresql=true

# params ############################################################

mysqlUser='remoteAdmin'
mysqlRootPwxd=1234
mysqlUserPwd=$mysqlRootPwd
mysqlBindIp=0.0.0.0
mysqlExternalAccess=true

pgsqlPwd='1234'
pgsqlExternalAccess=true
#####################################################################



printf "\033c" #clear screen
#sudo apt-get update
sudo locale-gen "en_GB.UTF-8"

# ------- Ngnix ------
if  [ ! dpkg -s nginx &>/dev/null ] && [ $nginx = true ]; then
	echo "-----------------------------------------------------------------------------"
	echo "@infojav: -----> Installing Ngnix"
	echo "-----------------------------------------------------------------------------"
	sudo apt-get install -y nginx

	sudo adduser vagrant www-data
	sudo rm /etc/nginx/sites-enabled/default
	sudo cp /vagrant/setup/nginx.conf /etc/nginx/sites-available/my-default
	sudo ln -s /etc/nginx/sites-available/my-default /etc/nginx/sites-enabled/default

	mkdir /etc/nginx/ssl 2>/dev/null
	openssl genrsa -out "/etc/nginx/ssl/n.key" 1024 2>/dev/null
	openssl req -new -key /etc/nginx/ssl/n.key -out /etc/nginx/ssl/n.csr -subj "/CN=n/O=Vagrant/C=UK" 2>/dev/null
	openssl x509 -req -days 365 -in /etc/nginx/ssl/n.csr -signkey /etc/nginx/ssl/n.key -out /etc/nginx/ssl/n.crt 2>/dev/null
fi

# ------- Curl -------
if [ ! dpkg -s curl &>/dev/null ] && [ $curl = true ]; then
	echo "-----------------------------------------------------------------------------"
	echo "@infojav: -----> Installing Curl"
	echo "-----------------------------------------------------------------------------"
	sudo apt-get install -y curl
	sudo apt-get install -y build-essential g++
fi

# ------- Git --------
if [ ! dpkg -s git &>/dev/null ] && [ $git = true ]; then
	echo "-----------------------------------------------------------------------------"
	echo "@infojav: -----> Installing git"
	echo "-----------------------------------------------------------------------------"
	sudo apt-get install -y git
fi

# ------- Redis ------
if [ ! dpkg -s redis-server &>/dev/null ] && [ $redis = true ]; then
	echo "-----------------------------------------------------------------------------"
	echo "@infojav: -----> Installing redis"
	echo "-----------------------------------------------------------------------------"
	sudo apt-get install -y redis-server
fi

# -------- Postgress ---
if [ ! dpkg -s postgresql-9.4 &>/dev/null ] && [ $postgresql = true ]; then
	echo "-----------------------------------------------------------------------------"
	echo "@infojav: ------> Installing portgresql"
	echo "-----------------------------------------------------------------------------"
	wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
	if [ ! -f /etc/apt/sources.list.d/pgdg.list ]; then
		sudo echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main 9.4" >> pgdg.list
		sudo cp pgdg.list /etc/apt/sources.list.d/pgdg.list
		sudo apt-get update
	fi
	sudo apt-get -y install postgresql-9.4 postgresql-client-9.4

	# Changing to dummy password" 
	sudo -u postgres psql postgres -c "ALTER USER postgres WITH ENCRYPTED PASSWORD '$pgsqlPwd'"

	if $pgsqlExternalAccess; then
		pgConfFile=/etc/postgresql/9.4/main/postgresql.conf
		pgHbaFile=/etc/postgresql/9.4/main/pg_hba.conf
		sudo sed -i.bak "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" $pgConfFile
		sudo printf "\nhost    all             all             10.0.2.2/32            md5\n" >> $pgHbaFile
	fi
fi

# ------- mysql ------
if [ ! dpkg -s mysql-server &>/dev/null ] && [ $mysql = true ]; then
	sudo apt-get install -y debconf-utils
	debconf-set-selections <<< "mysql-server mysql-server/root_password password $mysqlRootPwd"
	debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $mysqlRootPwd"
	echo "-----------------------------------------------------------------------------"
	echo "@infojav: -----> Installing mysql"
	echo "-----------------------------------------------------------------------------"
	sudo apt-get install -y mysql-server

	if $mysqlExternalAccess ; then
		sudo sed -i.bak "s/127.0.0.1/$mysqlBindIp/g" /etc/mysql/my.cnf
		mysql -u root -p$mysqlRootPwd mysql -e "CREATE USER $mysqlUser@'localhost' IDENTIFIED BY '$mysqlUserPwd';"
		mysql -u root -p$mysqlRootPwd mysql -e "CREATE USER $mysqlUser@'%' IDENTIFIED BY '$mysqlUserPwd';"
		mysql -u root -p$mysqlRootPwd mysql -e "GRANT ALL ON *.* TO $mysqlUser@'localhost';"
		mysql -u root -p$mysqlRootPwd mysql -e "GRANT ALL ON *.* TO $mysqlUser@'%';"
	fi
fi

# ------- MongoDB ----
if [ ! dpkg -s mongodb &>/dev/null ] && [ $mongodb = true ]; then
	echo "-----------------------------------------------------------------------------"
	echo "@infojav: -----> Installing mongodb"
	echo "-----------------------------------------------------------------------------"
	sudo apt-get install -y mongodb
fi


# ------- Memcached --
if [ ! dpkg -s memcached &>/dev/null ] && [ $memcahed = true ]; then
	echo "-----------------------------------------------------------------------------"
	echo "@infojav: -----> Installing Memcached"
	echo "-----------------------------------------------------------------------------"
	sudo apt-get install -y memcached
fi

# ------- PHP5 -------
if [ ! dpkg -s php5 &>/dev/null ] && [ $php5 = true ]; then
	echo "-----------------------------------------------------------------------------"
	echo "@infojav: -----> Installing PHP5"
	echo "-----------------------------------------------------------------------------"
	sudo apt-get install -y php5 php5-common php5-cli php5-fpm php5-intl php5-imagick php5-pgsql php5-gd php5-mcrypt php5-memcached php5-curl

	# ------- xdebug -----
	echo "-----------------------------------------------------------------------------"
	echo "@infojav: -----> Installing and setting xdebug for PHP"
	echo "-----------------------------------------------------------------------------"
	sudo apt-get install -y php5-xdebug
cat << 'EOF' | sudo tee -a /etc/php5/mods-available/xdebug.ini
xdebug.scream=1
xdebug.cli_color=1
xdebug.show_local_vars=1
EOF

	# ------- Composer ---
	echo "-----------------------------------------------------------------------------"
	echo "@infojav: -----> Composer"
	echo "-----------------------------------------------------------------------------"
	curl -sS https://getcomposer.org/installer | php
	sudo mv composer.phar /usr/local/bin/composer
fi

# ------- Install Java & Android SDK
if [ ! dpkg -s oracle-java8-installer &>/dev/null ] && [ $java = true ]; then
	echo "-----------------------------------------------------------------------------"
	echo "@infojav: -----> Java"
	echo "-----------------------------------------------------------------------------"
	#sudo apt-get install -y debconf-utils
	#sudo apt-add-repository -y ppa:webupd8team/java
	sudo apt-get update
	echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
	echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
	sudo apt-get install -y oracle-java8-installer


	if [ ! dpkg -s ant &>/dev/null ] && [ $android_sdk = true ]; then
		echo "-----------------------------------------------------------------------------"
		echo "@infojav: -----> Android SDK"
		echo "-----------------------------------------------------------------------------"
		#
		# http://askubuntu.com/questions/464400/comprehensive-guide-to-setup-android-sdk-with-eclipse-on-ubuntu-14-04-lts-64-bit
		#
		
		sudo apt-get -y install ant

		# For android development
		sudo dpkg --add-architecture i386
		sudo apt-get update
		sudo apt-get install -y lib32z1 libncurses5:i386 libstdc++6:i386 zlib1g:i386

		sdkDownloadFile=android-sdk_r24.3.3-linux.tgz
		if [ ! -f sdkDownloadFile]; then
			wget --quiet https://dl.google.com/android/android-sdk_r24.3.3-linux.tgz
		fi
		tar -xvzf android-sdk_r24.3.3-linux.tgz
		
		profileFile=/home/vagrant/.profile
		echo '' >> $profileFile
		echo '# Android SDK' >> $profileFile
		echo 'export ANDROID_SDK_HOME="/home/vagrant/android-sdk-linux"' >> $profileFile
		echo 'export PATH="$PATH:$ANDROID_SDK_HOME/tools"' >> $profileFile
		echo 'export PATH="$PATH:$ANDROID_SDK_HOME/platform-tools"' >> $profileFile
		source $profileFile
	fi
fi

# ------- Install Xvfb - X Virtual Frame Buffer
# For webdriver headless
if [ ! dpkg -s xvfb &>/dev/null ] && [ $webdriver = true ]; then
	echo "-----------------------------------------------------------------------------"
	echo "@infojav: -----> Installing Xvfb"
	echo "-----------------------------------------------------------------------------"
	sudo apt-get install -y xvfb
	sudo apt-get install -y xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic 
	sudo apt-get install -y x11-xkb-utils xserver-xorg-core dbus-x11
	sudo apt-get install -y libfontconfig1-devecho

	xvfbFile=/vagrant/setup/xvfb
	if [-f $xvfbFile]; then
		sudo cp $xvfbFile /etc/init.d/xvfb
	else
		printf '\n%s does not exist!\n' "$xvfbFile"
	fi
	sudo chmod a+x /etc/init.d/xvfb
	sudo update-rc.d xvfb defaults

cat << EOF | sudo tee -a /etc/environment
export DISPLAY=:10
EOF

	# ------- Install Browsers
	sudo apt-get install -y chromium-browser firefox
fi

# ------- nodejs -----
if [ ! dpkg -s nodejs &>/dev/null ] && [ $nodejs = true ]; then
	echo "-----------------------------------------------------------------------------"
	echo "@infojav: -----> Installing nodejs"
	echo "-----------------------------------------------------------------------------"
	sudo add-apt-repository -y ppa:chris-lea/node.js
	sudo apt-get update
	sudo apt-get purge -y node nodejs nodejs-legacy npm
	sudo apt-get install -y nodejs
	sudo apt-get install -y npm

	# ------- some npms
	echo "-----------------------------------------------------------------------------"
	echo "@infojav: -----> Installing some npms"
	echo "-----------------------------------------------------------------------------"
	sudo npm install -g bower
	sudo npm install -g grunt
	sudo npm install -g gulp
	sudo npm install -g express-generator
	sudo npm install -g yo

	if [ $webdriver = true ]; then
		sudo npm install -g protractor
		sudo webdriver-manager update
		sudo npm install -g phantomjs
		sudo npm install -g chromedriver
	fi

	if [ $android_sdk = true ]; then
		sudo npm install -g nativescript
	fi
fi

# ------- Selenium
if [ ! -f /etc/init.d/selenium ] && [ $webdriver = true ]; then
	echo "-----------------------------------------------------------------------------"
	echo "@infojav: ------> Installing selenium"
	echo "-----------------------------------------------------------------------------"
	sudo /usr/sbin/useradd -m -s /bin/bash -d /home/selenium selenium
	sudo mkdir /usr/local/share/selenium
	wget http://selenium.googlecode.com/files/selenium-server-standalone-2.37.0.jar
	seleniumServerFile = selenium-server-standalone-2.37.0.jar

	sudo cp $seleniumServerFile /usr/local/share/selenium
	sudo chown -R selenium:selenium /usr/local/share/selenium

	sudo mkdir /var/log/selenium
	sudo chown selenium:selenium /var/log/selenium

	seleniumFile = /vagrant/setup/selenium
	if [ -f $seleniumFile ]; then
		sudo cp $seleniumFile /etc/init.d/selenium
	else
		printf '\n%s does not exist!\n' "$seleniumFile"
	fi

	sudo chown root:root /etc/init.d/selenium
	sudo chmod a+x /etc/init.d/selenium
	sudo update-rc.d selenium defaults

	sudo touch /phantomjsdriver.log
	sudo chmod 666 /phantomjsdriver.log
fi

# -------- Imagemagick
if [ ! dpkg -s imagemagick &>/dev/null ] && [ $imagemagick = true ]; then
	echo "-----------------------------------------------------------------------------"
	echo "@infojav: ------> Installing imagemagick"
	echo "-----------------------------------------------------------------------------"
	sudo apt-get install -y imagemagick
fi



# -------- Starting services
echo "-----------------------------------------------------------------------------"
echo "@infojav: -----> Starting services"
echo "-----------------------------------------------------------------------------"
if [ $nginx = true ]; then
	echo "@infojav: ** nginx **"
	sudo service nginx restart &>/dev/null
	nginx -v
	echo "-----------------------------------------------------------------------------"
fi
if [ $postgresql = true ]; then
	echo "@infojav: ** postgresql **"
	sudo service postgresql restart &>/dev/null
	psql --version
	echo "-----------------------------------------------------------------------------"
fi
if [ $mysql = true ]; then
	echo "@infojav: ** mysql **"
	sudo service mysql restart &>/dev/null
	mysql --version
	echo "-----------------------------------------------------------------------------"
fi
if [ $redis = true ]; then
	echo "@infojav: ** redis **"
	sudo service redis-server restart &>/dev/null
	redis-server --version
	echo "-----------------------------------------------------------------------------"
fi
if [ $mongodb = true ]; then
	echo "@infojav: ** mongoDB **"
	sudo service mongodb restart &>/dev/null
	mongod --version
	echo "-----------------------------------------------------------------------------"
fi
if [ $php5 = true ]; then
	echo "@infojav: ** php **"
	php --version
	echo "-----------------------------------------------------------------------------"
fi
if [ $nodejs = true ]; then
	echo "@infojav: ** nodejs **"
	nodejs --version
	echo "-----------------------------------------------------------------------------"
fi
if [ $java = true ]; then
	echo "@infojav: ** java **"
	java -version
	echo "-----------------------------------------------------------------------------"
fi