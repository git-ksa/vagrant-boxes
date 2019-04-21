#!/usr/bin/env bash

# Vagrant Mattermost
# (c) 2016 Ian Dennis Miller
# http://github.com/iandennismiller/vagrant-mattermost

chmod 700 /vagrant

# update system
apt-get update
apt-get -y upgrade

# python
apt-get install -y python-pip
pip install virtualenvwrapper

# nginx
apt-get install -y nginx

# postgres
apt-get install -y postgresql postgresql-contrib

# git
apt-get install -y git

# mc

apt-get install -y mc