#!/bin/bash
# Version:	18.10
# Author:	Remo Rickli
# Description:	Install NeDi 1.7C on Ubuntu or Debian

clear
echo "Welcome to the Nebuntu install wizard!"
echo "-----------------------------------------------------------------"
echo "Please save IPv4 and IPv6 rules, when asked at iptables installation."
echo "Any existing 'nedi' database on this system will be reset!!!"
#read -p "Press enter to continue, ctrl-c to exit"

iptables -A PREROUTING -t nat -p udp --dport 514 -j REDIRECT --to-port 1514

apt update
echo
echo "Installing necessary packages"
echo "-----------------------------------------------------------------"
apt install -y libdbd-mysql-perl libnet-snmp-perl libnet-telnet-perl libsocket6-perl librrds-perl libalgorithm-diff-perl libcrypt-rijndael-perl 
apt install -y libcrypt-hcesha-perl libcrypt-des-perl libdigest-hmac-perl libio-pty-perl libwww-perl libnet-ntp-perl libnet-dns-perl perl-doc mariadb-client 
apt install -y mariadb-server php-fpm php-mysql php-snmp php-gd php-mcrypt php-ldap php-radius net-tools snmp rrdtool nginx openssl htop
#apt install -y iptables-persistent 

echo
echo "Installing NeDi 1.7 community edition"
echo "-----------------------------------------------------------------"
mkdir /var/nedi
cd /var/nedi
wget http://www.nedi.ch/pub/nedi-1.7C.pkg
tar zxf nedi-1.7C.pkg
rm nedi-1.7C.pkg
chown -R www-data:www-data /var/nedi
mkdir -p /var/log/nedi
chown -R www-data:www-data /var/log/nedi

/var/nedi/nedi.pl -i root dbpa55

if ! grep -q Time::HiRes /usr/share/perl5/Net/SNMP/Message.pm; then
  echo "Enabling SNMP latency measurement"
  sed -i '23 i use Time::HiRes;' /usr/share/perl5/Net/SNMP/Message.pm
  sed -i '687 i \ \ \ $this->{_transport}->{_send_time} = Time::HiRes::time;' /usr/share/perl5/Net/SNMP/Message.pm
fi

echo "Enabling snapshots"
echo "UPDATE mysql.user SET plugin='' WHERE user='root';"|mysql
echo "SET PASSWORD = PASSWORD('dbpa55');"|mysql
echo "FLUSH PRIVILEGES;"|mysql

if ! grep -q diffie-hellman-group1-sha1 /etc/ssh/ssh_config; then
  echo "Enabling SSH with DH-SHA1"
  echo "    KexAlgorithms=+diffie-hellman-group1-sha1" >> /etc/ssh/ssh_config
fi

PHPVER=`ls /etc/php`
echo
echo "Setting up php-fpm $PHPVER"
echo "-----------------------------------------------------------------"
sed -i -e 's/upload_max_filesize = 2M/upload_max_filesize = 8M/' /etc/php/$PHPVER/fpm/php.ini
service php$PHPVER-fpm restart

echo
echo "Setting up nginx"
echo "-----------------------------------------------------------------"
openssl genrsa -out /etc/ssl/private/server.key 1024
openssl req -new -key /etc/ssl/private/server.key -out /etc/ssl/server.csr -subj "/C=CH/ST=ZH/L=Zurich/O=NeDi Consulting/OU=R&D"
openssl x509 -req -days 365 -in /etc/ssl/server.csr -signkey /etc/ssl/private/server.key -out /etc/ssl/server.crt

cat > /etc/nginx/sites-enabled/default <<EOF
server {
  #listen   80; ## listen for ipv4; this line is default and implied
  #listen   [::]:80 default_server ipv6only=on; ## listen for ipv6

  client_max_body_size 128m;

  index index.php;
  server_name  localhost;
  listen       443;
  ssl                  on;
  ssl_certificate      /etc/ssl/server.crt;
  ssl_certificate_key  /etc/ssl/private/server.key;
  ssl_session_timeout  60m;
  ssl_session_cache    shared:SSL:1m;
  ssl_ciphers  HIGH:!aNULL:!MD5:!RC4;
  ssl_prefer_server_ciphers   on;
  root         /var/nedi/html;
  location /api {
    rewrite ^/api/(\w*)$ /query.php?t=\$1&q=\$args last;
  }
  location ~ \.php$ {
      fastcgi_split_path_info ^(.+\.php)(/.+)\$;
      fastcgi_param SCRIPT_FILENAME   \$document_root\$fastcgi_script_name;
      fastcgi_param QUERY_STRING              \$query_string;
      fastcgi_param REMOTE_ADDR               \$remote_addr;
      
      include        fastcgi_params;
      fastcgi_pass unix:/var/run/php/php$PHPVER-fpm.sock;
      fastcgi_buffering off;
   }

}
EOF
service nginx restart

echo
echo "Setting up syslog and monitoring startup scripts"
echo "-----------------------------------------------------------------"
cat > /etc/init.d/nedi-monitor <<EOF
#!/bin/sh
### BEGIN INIT INFO
# Provides:          nedi-monitor
# Required-Start:    mysql
# Required-Stop:
# Should-Start:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start NeDi's monitoring
# Description:       Monitored targets are checked every 3 minutes 
#                    by default, using snmp uptime or ping etc.
#                    
### END INIT INFO

PATH=/sbin:/usr/sbin:/bin:/usr/bin
. /lib/init/vars.sh

case "$1" in
  start|"")
    start-stop-daemon --start --chuid www-data --exec /var/nedi/moni.pl -- -D
    ;;
  stop)
    start-stop-daemon --stop --name moni.pl 
    RETVAL="\$?"

    sleep 1
    return "\$RETVAL"
    ;;
  *)
    echo "Usage: nedi-monitor [start|stop]" >&2
    exit 3
    ;;
esac

:
EOF
chmod 755 /etc/init.d/nedi-monitor
update-rc.d nedi-monitor defaults
service nedi-monitor start

###################################################
cat > /etc/init.d/nedi-syslog <<EOF
#!/bin/sh
### BEGIN INIT INFO
# Provides:          nedi-syslog
# Required-Start:    mysql
# Required-Stop:
# Should-Start:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start NeDi's syslog service
# Description:       Receive and stor syslog events in NeDi's events table
#                    
### END INIT INFO

PATH=/sbin:/usr/sbin:/bin:/usr/bin
. /lib/init/vars.sh

case "$1" in
  start|"")
    start-stop-daemon --start --chuid www-data --exec /var/nedi/syslog.pl -- -Dp 1514
    ;;
  stop)
    start-stop-daemon --stop --name syslog.pl 
    RETVAL="\$?"

    sleep 1
    return "\$RETVAL"
    ;;
  *)
    echo "Usage: nedi-syslog [start|stop]" >&2
    exit 3
    ;;
esac

:
EOF
chmod 755 /etc/init.d/nedi-syslog
update-rc.d nedi-syslog defaults
service nedi-syslog start

echo
echo "Finished!"
echo "Browse to host https://this-machine:4443 admin/admin and have fun!"
