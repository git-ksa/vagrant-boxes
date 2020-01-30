#https://computingforgeeks.com/resize-ext-and-xfs-root-partition-without-lvm/
echo "=== resize root partition from 40GB to 100GB"
yum -y install cloud-utils-growpart
growpart /dev/sda 1
lsblk
xfs_growfs /
df -hT | grep /dev/sda
echo "=== resize end"
yum install git -y
export PATH=/usr/local/bin:$PATH
systemctl stop firewalld
systemctl disable firewalld
iptables -L
git clone https://git.openstack.org/openstack/openstack-ansible /opt/openstack-ansible
cd /opt/openstack-ansible
git branch -a
git checkout stable/rocky
export ANSIBLE_FORCE_COLOR=true
scripts/bootstrap-ansible.sh
ls -ld /opt/*
ls -ltr /usr/local/bin/
which ansible
scripts/bootstrap-aio.sh
cd /opt/openstack-ansible/playbooks/
openstack-ansible setup-hosts.yml
openstack-ansible setup-infrastructure.yml
openstack-ansible setup-openstack.yml
netstat -pan | grep -i 443
grep keystone_auth_admin_password /etc/openstack_deploy/user_secrets.yml
#https://localhost:443