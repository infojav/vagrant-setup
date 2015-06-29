# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "ubuntu/trusty64"
  config.vm.provision "shell", path: "setup/bootstrap.sh"

  config.vm.network "forwarded_port", guest: 80, host: 8080	#nginx
  config.vm.network "forwarded_port", guest: 3306, host: 13306 #mysql
  config.vm.network "forwarded_port", guest: 5432, host: 15432	#pgsql
  config.vm.network "forwarded_port", guest: 3000, host: 13000	#node
  config.vm.network "forwarded_port", guest: 6379, host: 16379	#redis
  config.vm.network "forwarded_port", guest: 4444, host: 14444	#protractor
  config.vm.network "forwarded_port", guest: 27017, host: 27017 #mongodb

  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--memory", "1024"]
  end

  config.vm.network "private_network", ip: "192.168.33.10"

  config.vm.synced_folder "../../src", "/srv", create: true
end
