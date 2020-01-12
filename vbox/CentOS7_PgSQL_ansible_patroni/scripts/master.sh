# Insall EPEL repository

yum -y install epel-release

# Disable firewall and SELinux
systemctl disable firewalld
systemctl stop firewalld
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
#reboot

yum -y install git ansible python-psycopg2

ansible --version

cp -r /vagrant/* /home/vagrant

chown -R vagrant:vagrant /home/vagrant/

ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa

sed -i -e "s|#ChallengeResponseAuthentication yes|ChallengeResponseAuthentication yes|g" /etc/ssh/sshd_config
sed -i -e "s|ChallengeResponseAuthentication no|#ChallengeResponseAuthentication no|g" /etc/ssh/sshd_config
service sshd restart

echo "vagrant" | sshpass  ssh-copy-id root@192.168.4.2 -f  -o StrictHostKeyChecking=no
echo "vagrant" | sshpass  ssh-copy-id root@192.168.4.3 -f  -o StrictHostKeyChecking=no
echo "vagrant" | sshpass  ssh-copy-id root@192.168.4.4 -f  -o StrictHostKeyChecking=no

cat > pg.sh << EOF
export ANSIBLE_FORCE_COLOR=true
ansible-playbook -i inventory /home/vagrant/roles/postgresql_cluster/deploy_pgcluster.yml

EOF
sh pg.sh
# check version and replication
su -l postgres -c "psql --version"
# check version and replication
su -l postgres -c "psql --version"
su -l postgres -c "psql -c \"SELECT pid,usesysid,usename,client_addr,client_port,backend_start,state,sync_priority,sync_state FROM pg_stat_replication;\""

