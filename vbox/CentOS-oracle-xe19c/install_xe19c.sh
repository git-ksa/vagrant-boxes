#!/bin/bash
#

echo 'INSTALLER: Started up'

yum install epel-release mc wget unzip rlwrap openssl -y
yum install htop -y

echo 'INSTALLER: Oracle preinstall'

# RHEL7 
curl -o oracle-database-preinstall-19c-1.0-1.el7.x86_64.rpm https://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/getPackage/oracle-database-preinstall-19c-1.0-1.el7.x86_64.rpm
yum -y localinstall oracle-database-preinstall-19c-1.0-1.el7.x86_64.rpm
rm oracle-database-preinstall-19c-1.0-1.el7.x86_64.rpm 

echo 'INSTALLER: Oracle XE 19c install'
yum -y localinstall /vagrant/oracle-database-ee-19c-1.0-1.x86_64.rpm

echo 'INSTALLER: Oracle software installed'
echo 'INSTALLER: Create database ORCLCDB'

(echo "GetStarted19c"; echo "GetStarted19c";) | /etc/init.d/oracledb_ORCLCDB-19c configure 

echo 'INSTALLER: set oracle ORCLCDB autostart'

systemctl daemon-reload
systemctl enable oracledb_ORCLCDB-19c

# Check installed RPM's
rpm -qa | grep oracle

cat > /home/oracle/setEnv.sh <<EOF 
export ORACLE_HOME=/opt/oracle/product/19c/dbhome_1
export ORACLE_SID=ORCLCDB
export PATH=\$ORACLE_HOME/bin:\$PATH
EOF

cat >> /home/oracle/.bash_profile <<EOF
. /home/oracle/setEnv.sh
EOF

# check DB connect
export ORACLE_HOME=/opt/oracle/product/19c/dbhome_1
export ORACLE_SID=ORCLCDB
export PATH=$PATH:/opt/oracle/product/19c/dbhome_1/bin

sqlplus sys/GetStarted19c@//localhost:1521/ORCLCDB as sysdba <<EOF
select * from dual;
quit
EOF
