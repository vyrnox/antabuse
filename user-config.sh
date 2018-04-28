#!/bin/bash

if [ ! -e "/home/vagrant/provisioned.lock" ]
then
    echo "export DISCORD_API_KEY=${DISCORD_API_KEY}" >> /home/vagrant/.profile
    echo "Running 'mix local.hex --force'"
    mix local.hex --force
    echo "Running 'mix local.rebar --force'"
    mix local.rebar --force
    echo "Running 'yes | MIX_ENV=prod mix do deps.get, compile, test'"
    cd /vagrant
    yes | MIX_ENV=prod mix do deps.get
    yes | MIX_ENV=prod mix do compile
    yes | MIX_ENV=prod DISCORD_API_KEY=${DISCORD_API_KEY} mix do test
    # Run this sucker manually for now.
fi


