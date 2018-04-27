#!/bin/bash

if [ ! -e "/home/vagrant/provisioned.lock" ]
then
    echo "Running 'mix local.hex --force'"
    mix local.hex --force
    echo "Running 'mix local.rebar --force'"
    mix local.rebar --force
    echo "Running 'yes | MIX_ENV=prod mix do deps.get, compile, test'"
    cd /vagrant
    yes | MIX_ENV=prod mix do deps.get, compile, test
fi


