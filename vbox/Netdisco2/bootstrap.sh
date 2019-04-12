#!/bin/bash

# loosely following http://search.cpan.org/~oliver/App-Netdisco-2.019003/lib/App/Netdisco.pm

apt-get update
apt-get install -y postgresql curl libsnmp-perl make libdbd-pg-perl nginx mc htop

# It's random and long, right? :-/
PASSWORD="$(uuidgen)"

su - postgres -c 'createuser netdisco -D -R -S'
su - postgres -c 'createdb netdisco -O netdisco'
su - postgres -c "psql -c \"alter user netdisco with password '$PASSWORD'\""

useradd -m -s /bin/bash -p netdisco netdisco

echo "$PASSWORD" > /dev/shm/password

su - netdisco -c /vagrant/netdisco-bootstrap.sh

rm /dev/shm/password

cat <<EOF >/etc/nginx/sites-enabled/netdisco
server {
	listen 8080;
	location / {
		proxy_pass        http://localhost:5000;
		proxy_pass_header Server;
	}
}
EOF

/etc/init.d/nginx restart

crontab -u netdisco /vagrant/netdisco.crontab

#netdisco=# select * from users;
# username |                              password                               |          creation          |          last_on           | port_control | ldap | admin | fullname | note
#----------+---------------------------------------------------------------------+----------------------------+----------------------------+--------------+------+-------+----------+------
# admin    | {CRYPT}$2a$04$jeatx8WOoHvPEsy.TMRXIOKXdRdfN883uWoftx1.cWSNEnOgbkaDG | 2018-10-24 12:12:58.543102 | 2018-10-24 12:13:13.184501 | t            | f    | t     |          |
#(1 row)

# rename user
# su - postgres -c "psql -d netdisco -c \"update users set username='admin' where username='y'\""
# set password 'admin' to user 'admin'
# su - postgres -c "psql -d netdisco -c \"update users set password='{CRYPT}\$2a\$04\$jeatx8WOoHvPEsy.TMRXIOKXdRdfN883uWoftx1.cWSNEnOgbkaDG' where username='admin'\""


echo "Netdisco: http://localhost:8080/  l:p  admin:admin"
echo "DB user l:p netdisco:$PASSWORD"