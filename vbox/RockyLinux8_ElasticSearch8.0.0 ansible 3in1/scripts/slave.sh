echo root:vagrant | chpasswd

systemctl stop firewalld
systemctl disable firewalld


#enable password auth
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
sed -i -e "s|#ChallengeResponseAuthentication yes|ChallengeResponseAuthentication yes|g" /etc/ssh/sshd_config
sed -i -e "s|ChallengeResponseAuthentication no|#ChallengeResponseAuthentication no|g" /etc/ssh/sshd_config
service sshd restart