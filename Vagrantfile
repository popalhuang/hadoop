# -*- mode: ruby -*-
# vi: set ft=ruby :

MASTER_IP	= '192.168.51.4'
DN1_IP		= '192.168.51.5'
DN2_IP		= '192.168.51.6'

Vagrant.configure("2") do |config|
  #config.ssh.username="hadoop"
  #config.ssh.password="hadoop"
  #config.ssh.insert_key =true
  config.ssh.insert_key =false  
   
  #define data1 server
  config.vm.define "slave1" do |slave1|
    slave1.vm.hostname = "hadoop-slave1"
    slave1.vm.box = "ubuntu/yakkety64"
	slave1.vm.synced_folder ".", "/home/vagrant/src", mount_options: ["dmode=775,fmode=664"]
    slave1.vm.network "private_network", ip: DN1_IP
    slave1.vm.provider "virtualbox" do |v|
      v.name = "slave1"
      v.cpus = 1
      v.memory = 3500
    end    
	slave1.vm.provision "shell", path: "bootstrap-slave.sh"
  end

  #define data2 server
  config.vm.define "slave2" do |slave2|
    slave2.vm.hostname = "hadoop-slave2"
    slave2.vm.box = "ubuntu/yakkety64"
  	slave2.vm.synced_folder ".", "/home/vagrant/src", mount_options: ["dmode=775,fmode=664"]
    slave2.vm.network "private_network", ip: DN2_IP
    slave2.vm.provider "virtualbox" do |v|
      v.name = "slave2"
      v.cpus = 1
      v.memory = 2500
    end
  	slave2.vm.provision "shell", path: "bootstrap-slave.sh"
  end
  
  #define Master server
  config.vm.define "master" do |master|
    master.vm.hostname = "hadoop-master"
    master.vm.box = "ubuntu/yakkety64"
    master.vm.synced_folder ".", "/home/vagrant/src", mount_options: ["dmode=775,fmode=664"]
    master.vm.network "private_network", ip: MASTER_IP
    master.vm.provider "virtualbox" do |v|
      v.name = "master"
      v.cpus = 1
      v.memory = 2500
    end    
    master.vm.provision "shell", path: "bootstrap-master.sh"
  	#master.vm.provision "shell", path: "bootstrap-complete.sh", run: "always"
  	#master.vm.provision "shell", path: "bootstrap-complete.sh", run: "always",privileged: false
  end   
  
end