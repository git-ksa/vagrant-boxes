#!/bin/bash
#

echo 'INSTALLER: Install additional packages'

yum install epel-release mc wget unzip rlwrap openssl -y
yum install htop net-tools telnet -y

# NFS
yum install nfs-utils -y


systemctl enable rpcbind nfs-server
systemctl start rpcbind nfs-server

#��������� ��� ����� ������ NFS �������� ��������� ����������� ��� NFS-������:

rpcinfo -p localhost

#   program vers proto   port  service
#..
#    100003    3   tcp   2049  nfs
#    100003    4   tcp   2049  nfs
#    100003    3   udp   2049  nfs
#    100003    4   udp   2049  nfs
#...
#��� �����, ��� NFS ������ ������ ��������� ����������� ��� NFSv3 ��� � NFSv4.

#������ ������� ��� NFS-����

mkdir -p /nfs
chmod -R 777 /nfs

#������ NFS-���� � ����� /etc/exports:
# cat /etc/exports

echo  "/nfs 10.0.0.0/8(rw,sync,no_root_squash,no_all_squash)" >> /etc/exports

#/var/nfs 10.0.0.0/8(rw,sync,no_root_squash,no_all_squash)
#exit 

exportfs

#/var/nfs
#        10.1.1.0/24

systemctl stop firewalld
systemctl disable firewalld

#firewall-cmd --permanent --zone=public --add-service=nfs
#firewall-cmd --permanent --zone=public --add-service=mountd
#firewall-cmd --permanent --zone=public --add-service=rpc-bind
#firewall-cmd --reload

