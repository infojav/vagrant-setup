#!/usr/bin/env bash

sudo apt-get update

# ------- Ngnix ------
echo "@jav: -----> Installing Ngnix"
sudo apt-get install -y nginx

# ------- Curl -------
echo "@jav: -----> Installing Curl"
sudo apt-get install -y curl

# ------- Git --------
echo "@jav: -----> Installing git"
sudo apt-get install -y git

# ------- Redis ------
echo "@jav: -----> Installing redis"
sudo apt-get install -y redis-server
sudo apt-get install -y redis-cli

# ------- MongoDB ----
echo "@jav: -----> Installing mongodb"
sudo apt-get install -y mongodb


# ------- Memcached --
echo "@jav: -----> Installing Memcached"
sudo apt-get install -y memcached

# ------- PHP5 -------
echo "@jav: -----> Installing PHP5"
sudo apt-get install -y php5 php5-common php5-cli php5-fpm php5-intl php5-imagick php5-pgsql php5-gd php5-mcrypt php5-memcached php5-curl

# ------- PHP5 x-debug
echo "@jav: -----> Installing and setting xdebug for PHP"
sudo apt-get install -y php5-xdebug

cat << EOF | sudo tee -a /etc/php5/mods-available/xdebug.ini
xdebug.scream=1
xdebug.cli_color=1
xdebug.show_local_vars=1
EOF

# ------- Composer ---
echo "@jav: -----> Composer"
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# ------- Install Java
echo "@jav: -----> Java"
sudo apt-get install default-jre
#udo apt-get install default-jdk

# ------- Install Xvfb - X Virtual Frame Buffer
# For webdriver headless
echo "@jav: -----> Installing Xvfb"
sudo apt-get install -y xvfb
sudo apt-get install -y xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic 
sudo apt-get install -y x11-xkb-utils xserver-xorg-core dbus-x11
sudo apt-get install -y libfontconfig1-dev

sudo mv /vagrant/setup/xvfb /etc/init.d/xvfb
sudo chmod a+x /etc/init.d/xvfb
sudo update-rc.d xvfb defaults

cat << EOF | sudo tee -a /etc/environment
export DISPLAY=:10
EOF

# ------- Install Browsers
sudo apt-get install -y chromium-browser firefox

# ------- nodejs -----
echo "@jav: -----> Installing nodejs"
sudo add-apt-repository -y ppa:chris-lea/node.js
sudo apt-get update
sudo apt-get purge -y node nodejs nodejs-legacy npm
sudo apt-get install -y nodejs
sudo apt-get install -y npm

# ------- some npms
echo "@jav: -----> Installing some npms"
sudo npm install -g bower
sudo npm install -g grunt
sudo npm install -g gulp
sudo npm install -g express-generator
sudo npm install -g yo
sudo npm install -g protractor
sudo webdriver-manager update
sudo npm install -g phantomjs
sudo npm install -g chromedriver

# ------- Selenium
echo "@jav: ------> Installing selenium"
sudo /usr/sbin/useradd -m -s /bin/bash -d /home/selenium selenium
sudo mkdir /usr/local/share/selenium
wget http://selenium.googlecode.com/files/selenium-server-standalone-2.37.0.jar
sudo mv selenium-server-standalone-2.37.0.jar /usr/local/share/selenium
sudo chown -R selenium:selenium /usr/local/share/selenium

sudo mkdir /var/log/selenium
sudo chown selenium:selenium /var/log/selenium

sudo mv /vagrant/setup/selenium /etc/init.d/selenium
sudo chown root:root /etc/init.d/selenium
sudo chmod a+x /etc/init.d/selenium
sudo update-rc.d selenium defaults

sudo touch /phantomjsdriver.log
sudo chmod 666 /phantomjsdriver.log

# -------- Imagemagick
echo "@jav: ------> Installing imagemagick"
sudo apt-get install -y imagemagick

# ------- Postgress ---
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main 9.4" >> pgdg.list
sudo cp pgdg.list /etc/apt/sources.list.d/pgdg.list
sudo apt-get update
sudo apt-get -y install postgresql-9.4 postgresql-client-9.4

echo "@jav: -----> Changing to dummy password"
sudo pg_createcluster 9.4 test 
sudo vi /etc/postgresql/9.4/test/pg_hba.conf 
sudo -u postgres psql postgres -c "ALTER USER postgres WITH ENCRYPTED PASSWORD 'postgres'"
# Edit to allow socket access, not just local unix access
echo "@jav: -----> Patching pg_hba to change -> socket access"
sudo cp /etc/postgresql/9.4/test/pg_hba.conf .
sudo chmod a+rw pg_hba.conf
sudo sed 's/local.*all.*postgres.*peer/local all postgres md5/' < pg_hba.conf > pg_hba2.conf
sudo sed 's/local.*all.*all.*peer/local all all md5/' < pg_hba2.conf > pg_hba3.conf
echo "@jav: -----> Altered login to use md5 not peer:"
sudo printf "\nhost    all             all             127.0.0.1/32            trust\n" >> pg_hba3.conf

cat pg_hba3.conf

sudo chmod u-rw pg_hba3.conf 
sudo cp pg_hba3.conf /etc/postgresql/9.4/test/pg_hba.conf
echo "@jav: -----> Patching complete, restarting"

# -------- Iniciando Servicios
echo "@jav: -----> Iniciando Servicios"
echo "@jav: ** nginx **"
sudo service nginx restart
echo "@jav: ** postgresql **"
sudo /etc/init.d/postgresql restart


