echo 'Install nodejs and others'
rpm --import http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7
yum install epel-release -y
yum install mc telnet net-tools git nodejs -y
echo 'Clonning haste-server repo'
git clone https://github.com/seejohnrun/haste-server
echo 'Install memcache'
yum install memcached -y
systemctl enable memcached
systemctl start memcached
systemctl status memcached
npm install memcached
echo 'Install haste-server'
cd /home/vagrant/haste-server
npm install
echo 'Start haste-server'
echo 'Open http://host_ip:80'
npm start
