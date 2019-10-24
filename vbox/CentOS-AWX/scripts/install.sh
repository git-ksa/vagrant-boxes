# Insall EPEL repository
yum -y install epel-release

# Disable firewall and SELinux
systemctl disable firewalld
systemctl stop firewalld
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
#reboot

# Enable continuous release (CR) repository if some paskage from EPEL are dependant on newer release
yum -y install git gettext ansible docker nodejs npm gcc-c++ bzip2
yum -y install python-pip
pip install docker docker-compose

#  Start and enable docker service
systemctl start docker
systemctl enable docker

# Clone repository and deploy (it will take about 20 minutes)
git clone https://github.com/ansible/awx.git
cd awx/installer/
ansible-playbook -i inventory install.yml

# Monitor migrations status (it will take about 10 minutes)
docker logs -f awx_task
echo 'Now you can access AWX web server http://localhost:8080'
echo 'default administrator username is admin, and the password is password'
#The default administrator username is admin, and the password is password