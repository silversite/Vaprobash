#!/usr/bin/env bash

curl -L github https://github.com/sonata-project/sandbox-build/archive/master.tar.gz | tar xzv


sudo apt-get -qq -y install language-pack-pl
sudo locale-gen pl_PL.UTF-8

sudo apt-get -qq -y install mc
sudo apt-get -qq -y install htop
# Install ZSH
sudo apt-get -qq -y install zsh
wget --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sudo ZSH=/home/vagrant/.oh-my-zsh sh
export ZSH=/home/vagrant/.oh-my-zsh
sudo chsh -s /bin/zsh vagrant
zsh

cd /vagrant

curl -L github https://github.com/sonata-project/sandbox-build/archive/master.tar.gz | tar xzv

composer install
app/console doctrine:schema:update --force
app/console cache:clear
app/console assets:install web --symlink

#TODO Change this!! This is temp data
app/console fos:user:create admin admin demo@demo.sonata.dev --super-admin

app/console sonata:page:create-site --enabled=true --name=localhost--locale=- --host=localhost --relativePath=/ --enabledFrom=now --enabledTo="+10 years" --default=true -n
app/console sonata:page:update-core-routes --site=all
app/console sonata:page:create-snapshots --site=all

HTTPDUSER=`ps aux | grep -E '[a]pache|[h]ttpd|[_]www|[w]ww-data|[n]ginx' | grep -v root | head -1 | cut -d\  -f1`
sudo setfacl -R -m u:"$HTTPDUSER":rwX -m u:`whoami`:rwX /vagrant/app/cache /vagrant/app/logs
sudo setfacl -dR -m u:"$HTTPDUSER":rwX -m u:`whoami`:rwX /vagrant/app/cache /vagrant/app/logs
