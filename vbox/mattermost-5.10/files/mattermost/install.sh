#!/usr/bin/env bash

# Vagrant Mattermost
# (c) 2016 Ian Dennis Miller
# http://github.com/iandennismiller/vagrant-mattermost

# This script is derived from http://docs.mattermost.com/install/prod-ubuntu.html

# See http://www.mattermost.org/download/ for latest version
MM_VERSION=5.10.0

# database: mattermost
sudo -u postgres psql -c "CREATE DATABASE mattermost;"
sudo -u postgres psql -c "CREATE USER mmuser WITH PASSWORD 'mmuser_password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE mattermost to mmuser;"

# user: mattermost
useradd --system --user-group --create-home mattermost

# Download the latest Mattermost Server
if [ ! -f /home/mattermost/mattermost-team-${MM_VERSION}-linux-amd64.tar.gz ]; then
    rm -rf /home/mattermost/mattermost
    wget -q https://releases.mattermost.com/${MM_VERSION}/mattermost-team-${MM_VERSION}-linux-amd64.tar.gz
    tar xvzf mattermost-team-${MM_VERSION}-linux-amd64.tar.gz
    chown -R mattermost:mattermost ./mattermost
    mv ./mattermost /home/mattermost/mattermost
fi

# Configure and start Mattermost server
chown -R mattermost:mattermost /home/mattermost/mattermost
cp /vagrant/files/mattermost/config.json /home/mattermost/mattermost/config/config.json
cp /vagrant/files/mattermost/upstart.conf /etc/init/mattermost.conf
start mattermost

# Configure nginx to proxy Mattermost
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-enabled/mattermost
rm /etc/nginx/sites-available/default
cp /vagrant/files/mattermost/nginx.conf /etc/nginx/sites-available/mattermost
ln -s /etc/nginx/sites-available/mattermost /etc/nginx/sites-enabled/mattermost
service nginx restart

# configure SSL
if [ ! -d /home/mattermost/letsencrypt ]; then
    git clone https://github.com/letsencrypt/letsencrypt /home/mattermost/letsencrypt
    chown -R mattermost /home/mattermost/letsencrypt
fi

# cd /home/mattermost/letsencrypt && ./letsencrypt-auto certonly --standalone

# add letsencrypt cron job
# crontab -e
# @monthly /home/ubuntu/letsencrypt/letsencrypt-auto certonly --reinstall -d yourdomainname && sudo service nginx reload

# Update Email Settings. We recommend using an email sending service. The example shows how an Amazon SES setup might look (sample credentials shown below are not real).
# Set Send Email Notifications to true
# Set Require Email Verification to true
# Set Feedback Name to No-Reply
# Set Feedback Email to mattermost@example.com
# Set SMTP Username to [YOUR_SMTP_USERNAME]
# Set SMTP Password to [YOUR_SMTP_PASSWORD]
# Set SMTP Server to email-smtp.us-east-1.amazonaws.com
# Set SMTP Port to 465
# Set Connection Security to TLS
# Save the Settings

# Update Rate Limit Settings.
# Set Vary By Remote Address to false
# Set Vary By HTTP Header to X-Real-IP
