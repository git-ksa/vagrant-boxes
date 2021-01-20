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
#ansible-galaxy install geerlingguy.mysql
#mv /root/.ansible/roles/ /home/vagrant/
# or git 
#git clone https://github.com/geerlingguy/ansible-role-mysql
cp -r /vagrant/* /home/vagrant

chown -R vagrant:vagrant /home/vagrant/

cat > hosts <<EOF
[database]
db01  ansible_connection=local ansible_python_interpreter="/usr/bin/python"
EOF

cat > my_plb.yaml <<EOF
- hosts: database
  become: yes
  any_errors_fatal: true

  roles:
    - role: mysql

# Set this to `true` to forcibly update the root password.
      mysql_user_password_update: true
      mysql_root_password_update: true
      tags:
        - mysql
EOF

cat > my.sh << EOF
export ANSIBLE_FORCE_COLOR=true
ansible-playbook -i hosts my_plb.yaml
EOF

sh my.sh

service mariadb status

#CREATE USER 'user'@'%' IDENTIFIED BY 'password';
#GRANT ALL PRIVILEGES ON *.* TO 'user'@'%' WITH GRANT OPTION;
