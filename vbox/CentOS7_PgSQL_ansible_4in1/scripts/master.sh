# Insall EPEL repository

yum -y install epel-release

# Disable firewall and SELinux
systemctl disable firewalld
systemctl stop firewalld
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
#reboot

#yum install mc telnet net-tools -y
yum -y install git ansible python-psycopg2

ansible --version

# galaxy up to 11 version support
#ansible-galaxy  install anxs.postgresql
#mv /root/.ansible/roles/ /home/vagrant/

# for v12 support use github repo
git clone https://github.com/ANXS/postgresql /home/vagrant/roles/anxs.postgresql

mkdir -p /home/vagrant/host_vars
chown -R vagrant:vagrant /home/vagrant/

# based on https://severalnines.com/database-blog/postgresql-deployment-and-maintenance-ansible

cat > inventory <<EOF
[db]
#master  ansible_connection=local ansible_python_interpreter="/usr/libexec/platform-python"
master  ansible_host=192.168.4.2
slave1  ansible_host=192.168.4.3
slave2  ansible_host=192.168.4.4
slave3  ansible_host=192.168.4.5
EOF

#create host vars files
cat > /home/vagrant/host_vars/master.yaml <<EOF
postgresql_version: 9.6
postgresql_ext_install_contrib: yes
postgresql_listen_addresses: "*"
postgresql_max_connections: 150
postgresql_pg_hba_custom:
   - { type: host,  database: all, user: all, address: "10.0.0.0/8",   method: "{{ postgresql_default_auth_method_hosts }}", comment: "Enable external connections:" }
   - { type: host,  database: all, user: all, address: "192.168.4.0/24",   method: "{{ postgresql_default_auth_method_hosts }}", comment: "Enable external connections:" }
   - { type: host,  database: replication, user: all, address: "192.168.4.0/24",   method: "{{ postgresql_default_auth_method_hosts }}", comment: "Enable external connections:" }

#host    replication      postgres       10.0.0.0/8            md5
#host    all              postgres       10.0.0.0/8            md5

#prepare for standby
postgresql_wal_level: hot_standby
postgresql_wal_log_hints: on
postgresql_max_wal_senders: 8
postgresql_wal_keep_segments: 64
postgresql_hot_standby: on
postgresql_users:
   - name: replicate
     pass: replicate123
postgresql_databases:
   - name: db01
     owner: postgres
postgresql_user_privileges:
   - name: replicate
     db: db01
     priv: "ALL"
     role_attr_flags: "CREATEDB"
EOF

cat > /home/vagrant/host_vars/slave1.yaml <<EOF
postgresql_version: 9.6
postgresql_ext_install_contrib: yes
postgresql_listen_addresses: "*"
postgresql_max_connections: 150
postgresql_pg_hba_custom:
   - { type: host,  database: all, user: all, address: "10.0.0.0/8",   method: "{{ postgresql_default_auth_method_hosts }}", comment: "Enable external connections:" }
   - { type: host,  database: all, user: all, address: "192.168.4.0/24",   method: "{{ postgresql_default_auth_method_hosts }}", comment: "Enable external connections:" }
EOF

cat > /home/vagrant/host_vars/slave2.yaml <<EOF
postgresql_version: 9.6
postgresql_ext_install_contrib: yes
postgresql_listen_addresses: "*"
postgresql_max_connections: 150
postgresql_pg_hba_custom:
   - { type: host,  database: all, user: all, address: "10.0.0.0/8",   method: "{{ postgresql_default_auth_method_hosts }}", comment: "Enable external connections:" }
   - { type: host,  database: all, user: all, address: "192.168.4.0/24",   method: "{{ postgresql_default_auth_method_hosts }}", comment: "Enable external connections:" }

EOF

cat > /home/vagrant/host_vars/slave3.yaml <<EOF
postgresql_version: 9.6
postgresql_ext_install_contrib: yes
postgresql_listen_addresses: "*"
postgresql_max_connections: 150
postgresql_pg_hba_custom:
   - { type: host,  database: all, user: all, address: "10.0.0.0/8",   method: "{{ postgresql_default_auth_method_hosts }}", comment: "Enable external connections:" }
   - { type: host,  database: all, user: all, address: "192.168.4.0/24",   method: "{{ postgresql_default_auth_method_hosts }}", comment: "Enable external connections:" }

EOF

cat > pg-m-s.yaml <<EOF
- hosts: db
  become: yes
  pre_tasks:
   - name: Enabling epel repository
     yum:
       name:
          - epel-release
       state: latest
     tags: software

   - name: Install packages
     yum:
       state: latest
       name:
          - zip
          - unzip
          - atop
          - wget
          - mytop
          - htop
          - mc
          - telnet
          - net-tools
     tags: software
   - name: Add IP address of all hosts to all hosts
     lineinfile:
          dest: /etc/hosts
          regexp: '.*{{ item }}$'
          line: "{{ hostvars[item].ansible_host }} {{item}}"
          state: present
     when: hostvars[item].ansible_host is defined
     with_items: "{{ groups.all }}"
     tags: etc_hosts
  roles:
    - role: anxs.postgresql
EOF

ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa

sed -i -e "s|#ChallengeResponseAuthentication yes|ChallengeResponseAuthentication yes|g" /etc/ssh/sshd_config
sed -i -e "s|ChallengeResponseAuthentication no|#ChallengeResponseAuthentication no|g" /etc/ssh/sshd_config
service sshd restart

echo "vagrant" | sshpass  ssh-copy-id root@192.168.4.2 -f  -o StrictHostKeyChecking=no
echo "vagrant" | sshpass  ssh-copy-id root@192.168.4.3 -f  -o StrictHostKeyChecking=no
echo "vagrant" | sshpass  ssh-copy-id root@192.168.4.4 -f  -o StrictHostKeyChecking=no
echo "vagrant" | sshpass  ssh-copy-id root@192.168.4.5 -f  -o StrictHostKeyChecking=no

cat > pg-m-s.sh << EOF
ansible-playbook -i inventory pg-m-s.yaml
EOF
sh pg-m-s.sh
