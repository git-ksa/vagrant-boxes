#from https://awx.wiki/installation
# 31.10.2019

yum -y install policycoreutils-python
semanage port -a -t http_port_t -p tcp 8050
semanage port -a -t http_port_t -p tcp 8051
semanage port -a -t http_port_t -p tcp 8052
setsebool -P httpd_can_network_connect 1


# Disable firewall and SELinux
systemctl disable firewalld
systemctl stop firewalld
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0

yum -y install epel-release
yum -y install centos-release-scl centos-release-scl-rh

yum install -y wget net-tools telnet
wget -O /etc/yum.repos.d/ansible-awx.repo https://copr.fedorainfracloud.org/coprs/mrmeee/ansible-awx/repo/epel-7/mrmeee-ansible-awx-epel-7.repo

echo "[bintraybintray-rabbitmq-rpm] 
name=bintray-rabbitmq-rpm 
baseurl=https://dl.bintray.com/rabbitmq/rpm/rabbitmq-server/v3.7.x/el/7/
gpgcheck=0 
repo_gpgcheck=0 
enabled=1" > /etc/yum.repos.d/rabbitmq.repo

echo "[bintraybintray-rabbitmq-erlang-rpm] 
name=bintray-rabbitmq-erlang-rpm 
baseurl=https://dl.bintray.com/rabbitmq-erlang/rpm/erlang/21/el/7/
gpgcheck=0 
repo_gpgcheck=0 
enabled=1" > /etc/yum.repos.d/rabbitmq-erlang.repo


yum -y install rabbitmq-server
yum -y install rh-git29
yum -y install rh-postgresql10 memcached
yum -y install nginx
yum -y install rh-python36
yum -y install --disablerepo='*' --enablerepo='copr:copr.fedorainfracloud.org:mrmeee:ansible-awx, base' -x *-debuginfo rh-python36*
yum install -y ansible-awx

scl enable rh-postgresql10 "postgresql-setup initdb"
systemctl start rh-postgresql10-postgresql.service
systemctl start rabbitmq-server
scl enable rh-postgresql10 "su postgres -c \"createuser -S awx\""
scl enable rh-postgresql10 "su postgres -c \"createdb -O awx awx\""
sudo -u awx scl enable rh-python36 rh-postgresql10 rh-git29 "GIT_PYTHON_REFRESH=quiet awx-manage migrate"

echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'root@localhost', 'password')" | sudo -u awx scl enable rh-python36 rh-postgresql10 "GIT_PYTHON_REFRESH=quiet awx-manage shell"
sudo -u awx scl enable rh-python36 rh-postgresql10 rh-git29 "GIT_PYTHON_REFRESH=quiet awx-manage create_preload_data" # Optional Sample Configuration
sudo -u awx scl enable rh-python36 rh-postgresql10 rh-git29 "GIT_PYTHON_REFRESH=quiet awx-manage provision_instance --hostname=$(hostname)"
sudo -u awx scl enable rh-python36 rh-postgresql10 rh-git29 "GIT_PYTHON_REFRESH=quiet awx-manage register_queue --queuename=tower --hostnames=$(hostname)"
wget -O /etc/nginx/nginx.conf https://raw.githubusercontent.com/MrMEEE/awx-build/master/nginx.conf

systemctl start awx
systemctl enable awx

rm -f /opt/awx/static/assets/logo-login.svg
rm -f /opt/awx/static/assets/llogo-header.svg
wget -O /opt/awx/static/assets/logo-login.svg https://raw.githubusercontent.com/ansible/awx-logos/master/awx/ui/client/assets/logo-login.svg
wget -O /opt/awx/static/assets/llogo-header.svg https://raw.githubusercontent.com/ansible/awx-logos/master/awx/ui/client/assets/logo-header.svg


rm -f /opt/awx/static/assets/favicon.ico
rm -f /opt/awx/static/favicon.ico
rm -f /opt/awx/static/rest_framework/docs/img/favicon.ico
rm -f /var/lib/awx/favicon.ico
echo '============================================================'
echo 'http://localhost:80 default login: admin password: password'
echo '============================================================'