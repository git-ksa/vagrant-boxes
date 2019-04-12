#!/bin/bash
echo 'INSTALLER: Install packages'

yum install epel-release mc wget unzip rlwrap openssl -y

echo 'INSTALLER: python36'

yum install python36 -y
yum install python36-devel -y

echo 'INSTALLER: pip'

wget https://bootstrap.pypa.io/get-pip.py
python3.6 get-pip.py

yum groupinstall 'Development Tools' -y

/usr/local/bin/pip3 install esrally

echo 'INSTALLER: latest git'
echo '
[wandisco-git]
name=Wandisco GIT Repository
baseurl=http://opensource.wandisco.com/centos/7/git/$basearch/
enabled=1
gpgcheck=1
gpgkey=http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco
' > /etc/yum.repos.d/wandisco-git.repo

rpm --import http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco

yum install git -y

echo 'INSTALLER: java-1.8.0-openjdk'
yum install java-1.8.0-openjdk -y

echo "export JAVA_HOME=$JAVA_HOME" >> /home/vagrant/.bashrc

su -l vagrant -c "esrally configure"

echo 'Start local host benchmark:'
echo '   esrally --distribution-version=5.4.0'
echo 'Start remote host benchmark:'
echo '   esrally --track=pmc --target-hosts=10.5.5.10:9200,10.5.5.11:9200,10.5.5.12:9200 --pipeline=benchmark-only'
