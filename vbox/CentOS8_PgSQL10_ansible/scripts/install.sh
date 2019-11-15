# Insall EPEL repository

yum -y install epel-release

# Disable firewall and SELinux
systemctl disable firewalld
systemctl stop firewalld
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
#reboot

yum install mc telnet net-tools htop -y
yum -y install git ansible python3-psycopg2

ansible --version

ansible-galaxy install geerlingguy.postgresql

cat > hosts <<EOF
[database]
#pg12      ansible_host=192.168.88.88 ansible_connection=ssh ansible_ssh_user=root ansible_ssh_pass=vagrant 
db01  ansible_connection=local ansible_python_interpreter="/usr/libexec/platform-python"
EOF

cat > pg.yaml <<EOF
- hosts: database
  roles:
    - role: geerlingguy.postgresql
      become: yes
  vars:
      postgresql_python_library: python3-psycopg2
      postgresql_databases:
         - name: pg10_db
      postgresql_users:
         - name: r00t
           password: rootroot
      postgresql_global_config_options:
         - option: listen_addresses
           value: '*'
         - option: ssl
           value: off
      postgresql_hba_entries:
         - { type: local, database: all, user: postgres, auth_method: peer }
         - { type: local, database: all, user: all, auth_method: peer }
         - { type: host, database: all, user: all, address: '127.0.0.1/32', auth_method: md5 }
         - { type: host, database: all, user: all, address: '::1/128', auth_method: md5 }
         - { type: host, database: all, user: all, address: '0.0.0.0/0', auth_method: md5 }
EOF

# copy role to vagrant user
cp -r /root/.ansible/roles/ /home/vagrant/

cat > /home/vagrant/roles/geerlingguy.postgresql/vars/RedHat-8.yml <<EOF
__postgresql_version: "10"
__postgresql_data_dir: "/var/lib/pgsql/data"
__postgresql_bin_path: "/usr/bin"
__postgresql_config_path: "/var/lib/pgsql/data"
__postgresql_daemon: postgresql
__postgresql_packages:
  - postgresql
  - postgresql-server
  - postgresql-contrib
EOF

chown -R vagrant:vagrant /home/vagrant/

ansible-playbook -i hosts pg.yaml -v
