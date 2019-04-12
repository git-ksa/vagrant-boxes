vagrant provision --provision-with master-key,node01-key,node02-key
vagrant ssh master -c 'chmod 400 ~/.ssh/*.key'
vagrant ssh master -c 'ansible-playbook /home/vagrant/openshift-ansible/playbooks/prerequisites.yml'
vagrant ssh master -c 'ansible-playbook /home/vagrant/openshift-ansible/playbooks/deploy_cluster.yml'
