echo 'pgdg-redhat-repo-latest.noarch.rpm'
yum install https://download.postgresql.org/pub/repos/yum/12/redhat/rhel-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm -y
echo 'Install the client packages:'
yum install postgresql12 mc telnet net-tools htop -y
echo 'Install the server packages:'
yum install postgresql12-server -y
echo 'Initialize the database and enable automatic start:'
/usr/pgsql-12/bin/postgresql-12-setup initdb
systemctl enable postgresql-12
systemctl start postgresql-12
echo 'Enable remote connection'
echo "listen_addresses = '*'" >> /var/lib/pgsql/12/data/postgresql.conf
su -l postgres -c "echo 'host      all     all     all     trust' >> /var/lib/pgsql/12/data/pg_hba.conf"
echo '===  Check installed DB version: ==='
su -l postgres -c "psql --version"
echo '=== Create user "vagrant" ==='
su -l postgres -c "psql -c \"CREATE USER vagrant WITH PASSWORD 'vagrant';\""
echo '=== Create database "db1" ==='
su -l postgres -c "psql -c \"CREATE database db12;\""
echo '=== Grant superuser permissions to "vagrant" ==='
su -l postgres -c "psql -c \"ALTER USER vagrant WITH SUPERUSER;\""
echo 'Restarting postgresql'
systemctl restart postgresql-12
