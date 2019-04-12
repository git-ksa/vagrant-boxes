#!/bin/bash

curl -L http://cpanmin.us/ | perl - --notest --verbose --local-lib ~/perl5 App::Netdisco

mkdir ~/bin
ln -s ~/perl5/bin/{localenv,netdisco-*} ~/bin/

mkdir ~/environments
cp ~/perl5/lib/perl5/auto/share/dist/App-Netdisco/environments/deployment.yml ~/environments
chmod +w ~/environments/deployment.yml

sed -i "s/user: .*/user: 'netdisco'/;s/pass: .*/pass: '$(cat /dev/shm/password)'/" ~/environments/deployment.yml

rm /dev/shm/password

#echo 'no_auth: true' >> environments/deployment.yml

sed -i -e "s|default => 'n'|default => 'y'|g" /home/netdisco/perl5/bin/netdisco-deploy
sed -i -e "s|username => \$name|username => 'admin'|g" /home/netdisco/perl5/bin/netdisco-deploy
sed -i -e "s|password => _make_password(\$pass)|password => _make_password('admin')|g" /home/netdisco/perl5/bin/netdisco-deploy

yes y | ~/bin/netdisco-deploy

~/bin/netdisco-web start --host=127.0.0.1
~/bin/netdisco-daemon start

