# Antabuse #

An elixir bot using nostrum for managing screaming alcoholics on Discord.

## Purpose ##

In order to provide more granular control over Discord's role based system, where
such roles are used for gamification ranking purposes, this bot provides a set
of commands to change user roles and perform other moderation tasks.

## Features ##

* !mute <user> 
```!mute <user> should save their roles, remove all of them, and apply the 'mute' role.```  

* !unmute <user>
```!unmute should remove the mute role and restore all the roles they had.```

## Running ##

With Vagrant:

    $ DISCORD_API_KEY=token vagrant up

With Elixir:

    $ mix local.hex --force
    $ mix local.rebar --force
    $ MIX_ENV=prod mix do deps.get
    $ MIX_ENV=prod mix do compile
    $ export DISCORD_API_KEY=token
    $ iex -S mix
