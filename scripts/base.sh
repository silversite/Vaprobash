#!/usr/bin/env bash

echo "Setting Timezone & Locale to $3 & en_US.UTF-8"

sudo ln -sf /usr/share/zoneinfo/$3 /etc/localtime

echo ">>> Installing Base Packages"

if [[ -z $1 ]]; then
    github_url="https://raw.githubusercontent.com/fideloper/Vaprobash/master"
else
    github_url="$1"
fi

# Update
sudo apt-get update

# Install base packages
# -qq implies -y --force-yes
sudo apt-get install -qq curl unzip git-core ack-grep software-properties-common build-essential cachefilesd


echo ">>> Installing *.xip.io self-signed SSL"

SSL_DIR="/etc/ssl/xip.io"
DOMAIN="*.xip.io"
PASSPHRASE="vaprobash"

SUBJ="
C=US
ST=Connecticut
O=Vaprobash
localityName=New Haven
commonName=$DOMAIN
organizationalUnitName=
emailAddress=
"

sudo mkdir -p "$SSL_DIR"

sudo openssl genrsa -out "$SSL_DIR/xip.io.key" 1024
sudo openssl req -new -subj "$(echo -n "$SUBJ" | tr "\n" "/")" -key "$SSL_DIR/xip.io.key" -out "$SSL_DIR/xip.io.csr" -passin pass:$PASSPHRASE
sudo openssl x509 -req -days 365 -in "$SSL_DIR/xip.io.csr" -signkey "$SSL_DIR/xip.io.key" -out "$SSL_DIR/xip.io.crt"

# Setting up Swap

# Disable case sensitivity
shopt -s nocasematch

if [[ ! -z $2 && ! $2 =~ false && $2 =~ ^[0-9]*$ ]]; then
    #https://gist.github.com/shovon/9dd8d2d1a556b8bf9c82
    echo ">>> Setting up Swap ($2 MB)"

    # does the swap file already exist?
    grep -q "swapfile" /etc/fstab

    # Create the Swap file
    sudo fallocate -l $2M /swapfile

    # if not then create it
	if [ $? -ne 0 ]; then
	  echo 'swapfile not found. Adding swapfile.'
	  sudo fallocate -l $2M /swapfile
	  sudo chmod 600 /swapfile
	  sudo mkswap /swapfile
	  sudo swapon /swapfile
	  echo '/swapfile none swap defaults 0 0' >> /etc/fstab
	else
	  echo 'swapfile found. No changes made.'
     fi
    #https://getcomposer.org/doc/articles/troubleshooting.md#proc-open-fork-failed-errors
    sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
    sudo /sbin/mkswap /var/swap.1
    sudo /sbin/swapon /var/swap.1	
fi

# output results to terminal
df -h
cat /proc/swaps
cat /proc/meminfo | grep Swap

# Enable case sensitivity
shopt -u nocasematch

# Enable cachefilesd
echo "RUN=yes" > /etc/default/cachefilesd
