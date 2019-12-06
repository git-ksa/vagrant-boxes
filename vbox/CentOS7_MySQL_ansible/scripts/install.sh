# Insall EPEL repository

yum -y install epel-release

# Disable firewall and SELinux
systemctl disable firewalld
systemctl stop firewalld
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
#reboot

yum install mc telnet net-tools htop -y
yum -y install git ansible python-psycopg2

ansible --version

# galaxy 
ansible-galaxy install geerlingguy.mysql
mv /root/.ansible/roles/ /home/vagrant/
# or git 
#git clone https://github.com/geerlingguy/ansible-role-mysql
chown -R vagrant:vagrant /home/vagrant/

cat > hosts <<EOF
[database]
db01  ansible_connection=local ansible_python_interpreter="/usr/libexec/platform-python"
EOF

cat > my.yaml <<EOF
- hosts: database
  become: yes
  any_errors_fatal: true
  roles:
    - role: geerlingguy.mysql
      mysql_root_password_update: true
      mysql_enabled_on_startup: true
      tags:
        - mysql
EOF

ansible-playbook -i hosts my.yaml 

service mariadb status