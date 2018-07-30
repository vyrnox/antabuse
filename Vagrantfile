# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrant::DEFAULT_SERVER_URL.replace('https://vagrantcloud.com')

discord_api_key = ENV['DISCORD_API_KEY'] ? ENV['DISCORD_API_KEY'] : 'NONESET'

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.box_version = "=20180427.0.0"
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end
  config.vm.provision "shell", path: "provision.sh", env: {"DISCORD_API_KEY" => discord_api_key}

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end
end
