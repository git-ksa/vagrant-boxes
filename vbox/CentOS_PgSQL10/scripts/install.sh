echo 'install pgdg-centos10-10-2.noarch.rpm'
yum install https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-x86_64/pgdg-centos10-10-2.noarch.rpm -y
echo 'Install the client packages:'
yum install postgresql10 mc telnet net-tools -y
echo 'Install the server packages:'
yum install postgresql10-server -y
echo 'Initialize the database and enable automatic start:'
/usr/pgsql-10/bin/postgresql-10-setup initdb
systemctl enable postgresql-10
systemctl start postgresql-10
echo 'Enable remote connection'
echo "listen_addresses = '*'" >> /var/lib/pgsql/10/data/postgresql.conf
su -l postgres -c "echo 'host      all     all     all     trust' >> /var/lib/pgsql/10/data/pg_hba.conf"
echo '===  Check installed DB version: ==='
su -l postgres -c "psql --version"
echo '=== Create user "vagrant" ==='
su -l postgres -c "psql -c \"CREATE USER vagrant WITH PASSWORD 'vagrant';\""
echo '=== Create database "db1" ==='
su -l postgres -c "psql -c \"CREATE database db1;\""
echo '=== Grant superuser permissions to "vagrant" ==='
su -l postgres -c "psql -c \"ALTER USER vagrant WITH SUPERUSER;\""
echo 'Restarting postgresql'
systemctl restart postgresql-10
