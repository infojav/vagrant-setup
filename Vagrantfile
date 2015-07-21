# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "ubuntu/trusty64"
  config.vm.provision "shell", path: "setup/bootstrap.sh"

  # Default Port Forwarding
  default_ports = {
    80   => 8000,
    443  => 44300,
    3000 => 30000,    #node
    3306 => 33060,    #mysql
    4444 => 44440,    #protractor
    5432 => 54320,    #pgsql
    6379 => 63790,    #redis
    27017 => 27017,   #mongodb
    8100 => 8100,    #android debuger
    35729 => 35729,   #
  }
  
  # Use Default Port Forwarding Unless Overridden
  default_ports.each do |guest, host|
      config.vm.network "forwarded_port", guest: guest, host: host, autocorrect: true
  end

  config.vm.network "private_network", ip: "192.168.33.10"

  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--memory", "1024", "--usb", "on"]
    v.customize ["usbfilter", "add", "0", "--target", :id, "--name", "android", "--vendorid", "0x18d1"]
  end

  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"  
  config.vm.synced_folder "../../src", "/srv", create: true, owner: "www-data", group: "www-data"

end
