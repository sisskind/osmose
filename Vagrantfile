# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.network "forwarded_port", guest: 20009, host: 20009

  config.vm.synced_folder ".", "/home/vagrant/osmose"
  config.vm.synced_folder "./osmose-backend", "/usr/local/osmose-backend"
  config.vm.synced_folder "./osmose-frontend", "/usr/local/osmose-frontend"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "4096"
  end
  
  # config.vm.provision "setup", type: "shell", :privileged => false, :path => "VagrantProvision.sh"
end

# Allow local overrides of vagrant settings
if File.exists?('VagrantfileLocal')
  load 'VagrantfileLocal'
end
