echo 'Install the client packages:'
yum install memcached mc telnet net-tools -y
systemctl enable memcached
systemctl start memcached
