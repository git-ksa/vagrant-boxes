# Vagrant-CentOS-PgSQL 9.4-12-ansible

Vagrant setup for PgSQL 9.4-12 on CentOS 7 via ansible playbook

### Prerequisites

* [Vagrant](https://www.vagrantup.com/intro/getting-started/install.html) - Vagrant manages virtual machines 
* [Virtualbox](https://www.virtualbox.org/wiki/Linux_Downloads) - Vagrant depends on virtualbox to run virtual machines 

### Installing

First install vagrant and virtualbox on your machine. 
After installing vagrant, just clone this github repo.

```
git clone https://github.com/krivegasa/vagrant-boxes.git
cd vagrant-boxes/vbox/CentOS7_PgSQL_ansible/
vagrant up
```
See PgSQL on

```
localhost:5432
```

Path to Postgres configs:

```
/etc/postgres/...
```
