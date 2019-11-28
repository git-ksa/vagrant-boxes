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

# galaxy up to 11 version support
#ansible-galaxy  install anxs.postgresql
#mv /root/.ansible/roles/ /home/vagrant/

# for v12 support use github repo
git clone https://github.com/ANXS/postgresql /home/vagrant/roles/anxs.postgresql
chown -R vagrant:vagrant /home/vagrant/

# based on https://severalnines.com/database-blog/postgresql-deployment-and-maintenance-ansible

cat > hosts <<EOF
[database]
db01  ansible_connection=local ansible_python_interpreter="/usr/libexec/platform-python"
EOF

cat > pg.yaml <<EOF
- hosts: database
  become: yes
  vars:
# 9.6 / 11 / 12
     postgresql_version: 9.6
     postgresql_ext_install_contrib: yes
     postgresql_listen_addresses: "*"
     postgresql_port: 5432
     postgresql_max_connections: 150
     postgresql_pg_hba_custom:
        - { type: host,  database: all, user: all, address: "10.0.0.0/8",   method: "{{ postgresql_default_auth_method_hosts }}", comment: "Enable external connections:" }
     postgresql_users:
           - name: user1
             pass: 11111111
           - name: user2
             pass: md5827ccb0eea8a706c4c34a16891f84e7b
             encrypted: yes
     postgresql_databases:
           - name: user1_db
             owner: user1
           - name: user2_db
             owner: user2
  roles: 
    - role: anxs.postgresql
EOF

ansible-playbook -i hosts pg.yaml 
