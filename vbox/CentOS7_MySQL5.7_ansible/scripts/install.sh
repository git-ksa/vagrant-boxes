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
db01  ansible_connection=local ansible_python_interpreter="/usr/libexec/platform-python"
EOF

cat > my_plb.yaml <<EOF
- hosts: database
  become: yes
  any_errors_fatal: true

  pre_tasks:
    - name: Install the MySQL repo.
      yum:
         name: http://dev.mysql.com/get/mysql57-community-release-el7-8.noarch.rpm 
         state: present

  roles:
    - role: mysql

# Set this to `true` to forcibly update the root password.
      mysql_user_password_update: true
      mysql_root_password_update: true
      mysql_enabled_on_startup: true
      mysql_user_password: ZB1C6(RxS-0
      mysql_root_password: ZB1C6(RxS-0
      mysql_datadir: /u01/mysql
      mysql_daemon: mysqld
      mysql_packages: ['mysql-server','MySQL-python'] 
      mysql_log_error: /var/log/mysqld.log
      mysql_syslog_tag: mysqld
      mysql_pid_file: /var/run/mysqld/mysqld.pid
      mysql_socket: /var/lib/mysql/mysql.sock
      mysql_databases:
        - name: example_db
      mysql_users:
        - name: user
          host: "%"
          password: ZB1C6(RxS-0
          priv: "*.*:ALL"
      tags:
        - mysql
EOF

cat > my.sh << EOF
export ANSIBLE_FORCE_COLOR=true
ansible-playbook -i hosts my_plb.yaml
EOF

sh my.sh

service mysqld status

#CREATE USER 'user'@'%' IDENTIFIED BY 'password';
#GRANT ALL PRIVILEGES ON *.* TO 'user'@'%' WITH GRANT OPTION;
