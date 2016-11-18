#!/usr/bin/env bash

sudo apt-get install language-pack-pl
sudo locale-gen pl_PL.UTF-8

sudo apt-get -qq -y install mc
sudo apt-get -qq -y update
sudo apt-get -qq -y upgrade
sudo apt-get -qq -y autoremove
