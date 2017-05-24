#!/bin/bash
# this script provisions the webserver
# created by https://github.com/tjgornick/sample_tfec2

# create filesystem on ebs vol, mount vol, add to fstab for auto-mount
sudo mkfs -t ext4 /dev/xvdh
sudo mkdir /data
sudo mount /dev/xvdh /data
echo '/dev/xvdh /data ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab

# update packages, install security patches, install nginx
sudo apt-get update -y
sudo unattended-upgrades -d
sudo apt-get install nginx -y

# replace default nginx page
sudo rm /etc/nginx/sites-enabled/default
sudo mv /tmp/sample /etc/nginx/sites-available/sample
sudo ln -f /etc/nginx/sites-available/sample /etc/nginx/sites-enabled/sample

# prep ebs document root and move index.html there
sudo mkdir -p /data/www/sample
sudo mv /tmp/index.html /data/www/sample/index.html

# enforce nginx user perms on document root
sudo chown -R www-data: /data/www/sample

# restart nginx to apply changes
sudo /etc/init.d/nginx restart
