# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.network "forwarded_port", guest: 80, host: 7000
  config.vm.network "forwarded_port", guest: 8080, host: 7100
  config.vm.network "forwarded_port", guest: 27017, host: 7200
  config.vm.provision "shell", path: "./scripts/vagrant-provision-vm.sh"
end
