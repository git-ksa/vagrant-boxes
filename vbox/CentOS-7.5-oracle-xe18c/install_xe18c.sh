#!/bin/bash
#

echo 'INSTALLER: Started up'

yum install epel-release mc wget unzip rlwrap openssl -y
yum install htop -y

echo 'INSTALLER: Oracle preinstall'

# RHEL7
curl -o oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm https://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/getPackage/oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm
yum -y localinstall oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm
rm oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm

echo 'INSTALLER: Oracle XE 18c install'
yum -y localinstall /vagrant/oracle-database-xe-18c-1.0-1.x86_64.rpm

echo 'INSTALLER: Oracle software installed'
echo 'INSTALLER: Create database XE'

(echo "GetStarted18c"; echo "GetStarted18c";) | /etc/init.d/oracle-xe-18c configure 

echo 'INSTALLER: set oracle XE autostart'

systemctl daemon-reload
systemctl enable oracle-xe-18c

# Check installed RPM's
rpm -qa | grep oracle

cat > /home/oracle/setEnv.sh <<EOF 
export ORACLE_HOME=/opt/oracle/product/18c/dbhomeXE
export ORACLE_SID=XE
export PATH=\$ORACLE_HOME/bin:\$PATH
EOF

cat >> /home/oracle/.bash_profile <<EOF
. /home/oracle/scripts/setEnv.sh
EOF

# check DB connect
export ORACLE_HOME=/opt/oracle/product/18c/dbhomeXE
export ORACLE_SID=XE
export PATH=$PATH:/opt/oracle/product/18c/dbhomeXE/bin

sqlplus sys/GetStarted18c@//localhost:1521/XE as sysdba <<EOF
select * from dual;
quit
EOF
