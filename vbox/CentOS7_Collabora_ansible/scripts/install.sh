# Insall EPEL repository

yum -y install epel-release
yum -y install git ansible python-psycopg2

ansible --version

cp -r /vagrant/* /home/vagrant

chown -R vagrant:vagrant /home/vagrant/

ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa

sed -i -e "s|#ChallengeResponseAuthentication yes|ChallengeResponseAuthentication yes|g" /etc/ssh/sshd_config
sed -i -e "s|ChallengeResponseAuthentication no|#ChallengeResponseAuthentication no|g" /etc/ssh/sshd_config
service sshd restart

echo "vagrant" | sshpass  ssh-copy-id root@192.168.4.2 -f  -o StrictHostKeyChecking=no

cat > collabora.sh << EOF
export ANSIBLE_FORCE_COLOR=true
ansible-playbook -i inventory collabora.yaml
EOF

sh collabora.sh

