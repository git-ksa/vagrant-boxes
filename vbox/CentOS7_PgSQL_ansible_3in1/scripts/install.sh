# Insall EPEL repository

yum -y install epel-release

# Disable firewall and SELinux
systemctl disable firewalld
systemctl stop firewalld
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
#reboot

#yum install mc telnet net-tools -y
yum -y install cowsay git ansible python-psycopg2

ansible --version

# galaxy up to 11 version support
#ansible-galaxy  install anxs.postgresql
#mv /root/.ansible/roles/ /home/vagrant/

# for v12 support use github repo
git clone https://github.com/ANXS/postgresql /home/vagrant/roles/anxs.postgresql

mkdir -p /home/vagrant/host_vars
chown -R vagrant:vagrant /home/vagrant/

# based on https://severalnines.com/database-blog/postgresql-deployment-and-maintenance-ansible

cat > hosts <<EOF
[db]
master  ansible_connection=local ansible_python_interpreter="/usr/libexec/platform-python"
#slave1  ansible_host=192.168.4.3 ansible_user=vagrant ansible_password=vagrant
#slave2  ansible_host=192.168.4.4 ansible_user=vagrant ansible_password=vagrant
slave1  ansible_host=192.168.4.3
slave2  ansible_host=192.168.4.4
EOF

#create host vars files
cat > /home/vagrant/host_vars/master.yaml <<EOF
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
postgresql_databases:
   - name: user1_db
     owner: user1
EOF

cat > /home/vagrant/host_vars/slave1.yaml <<EOF
postgresql_version: 9.6
postgresql_ext_install_contrib: yes
postgresql_listen_addresses: "*"
postgresql_port: 5432
postgresql_max_connections: 150
postgresql_pg_hba_custom:
   - { type: host,  database: all, user: all, address: "10.0.0.0/8",   method: "{{ postgresql_default_auth_method_hosts }}", comment: "Enable external connections:" }
EOF

cat > /home/vagrant/host_vars/slave2.yaml <<EOF
postgresql_version: 9.6
postgresql_ext_install_contrib: yes
postgresql_listen_addresses: "*"
postgresql_port: 5432
postgresql_max_connections: 150
postgresql_pg_hba_custom:
   - { type: host,  database: all, user: all, address: "10.0.0.0/8",   method: "{{ postgresql_default_auth_method_hosts }}", comment: "Enable external connections:" }
EOF

cat > pg-m-s-s.yaml <<EOF
- hosts: db
  become: yes
  pre_tasks:
   - name: Enabling epel repository
     yum: name={{ item }} state=latest
     tags: software
     with_items:
          - epel-release
   - name: Install packages
     yum: name={{ item }} state=latest
     tags: software
     with_items:
          - zip
          - unzip
          - atop
          - wget
          - mytop
          - htop
          - mc
          - telnet 
          - net-tools 
  roles:
    - role: anxs.postgresql

EOF

ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa

echo "vagrant" | sshpass  ssh-copy-id root@192.168.4.3 -f  -o StrictHostKeyChecking=no
echo "vagrant" | sshpass  ssh-copy-id root@192.168.4.4 -f  -o StrictHostKeyChecking=no

ansible-playbook -i hosts pg-m-s-s.yaml 
