#!/bin/sh

if [ ! -e "/home/vagrant/provisioned.lock" ]
then
    echo "set grub-pc/install_devices /dev/sda" | debconf-communicate
    cd /root
    echo "Installing Erlang Solutions repository."
    wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb
    echo "Updating and upgrading packages."
    apt-get update
    apt-get -y upgrade
    echo "Installing esl-erlang, elixir and redis."
    apt-get -y install esl-erlang elixir redis-server
    echo "Executing user-config.sh as vagrant."
    su -c "DISCORD_API_KEY=${DISCORD_API_KEY} source /vagrant/user-config.sh" vagrant
    touch /home/vagrant/provisioned.lock
fi
