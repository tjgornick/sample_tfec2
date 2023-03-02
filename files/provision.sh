#!/bin/bash
# This script provisions the webserver
# Created by https://github.com/tjgornick/sample_tfec2

# Create filesystem on ebs vol, mount vol, add to fstab for auto-mount
sudo mkfs -t ext4 /dev/xvdh
sudo mkdir /data
sudo mount /dev/xvdh /data
echo '/dev/xvdh /data ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab

# Update packages, install security patches, install nginx
sudo yum update -y
sudo amazon-linux-extras install -y nginx1
sudo systemctl start nginx.service
sudo systemctl enable nginx

# Create new nginx.conf via heredoc
cat << EOF > /tmp/new_nginx.conf
# Default server configuration
# for webserver created by https://github.com/tjgornick/sample_tfec2
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

    }
EOF

# Create new index file via heredoc
cat << EOF > /tmp/index.html
<!DOCTYPE html>
<html>
<head>
<title>Hello AWS World!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Hello AWS World!</h1>
</body>
</html>
EOF

# Create new website config via heredoc
cat << EOF > /tmp/sample.conf
# Default server configuration
# for webserver created by https://github.com/tjgornick/sample_tfec2
server {
      listen       80;
      listen       [::]:80;
      server_name  _;
      root         /data/www/sample;

      # Load configuration files for the default server block.
      include /etc/nginx/default.d/*.conf;

      error_page 404 /404.html;
      location = /404.html {
      }

      error_page 500 502 503 504 /50x.html;
      location = /50x.html {
      }
  }
EOF

# Replace default nginx page
sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
sudo mv /tmp/new_nginx.conf /etc/nginx/nginx.conf
sudo mv /tmp/sample.conf /etc/nginx/conf.d/sample.conf

# Prep ebs document root and move index.html there
sudo mkdir -p /data/www/sample
sudo mv /tmp/index.html /data/www/sample/index.html

# Enforce nginx user perms on document root
sudo chown -R nginx: /data/www/sample

# Restart nginx to apply changes
sudo systemctl restart nginx.service
