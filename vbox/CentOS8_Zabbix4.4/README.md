# vagrant-zabbix 4.4
Vagrant setup for zabbix 4.4 on CentOS 8.0

### Prerequisites

* [Vagrant](https://www.vagrantup.com/intro/getting-started/install.html) - Vagrant manages virtual machines 
* [Virtualbox](https://www.virtualbox.org/wiki/Linux_Downloads) - Vagrant depends on virtualbox to run virtual machines 

### Installing

First install vagrant and virtualbox on your machine. 

After installing vagrant, just clone this github repo.

```
git clone https://github.com/krivegasa/vagrant-boxes.git
cd vagrant-boxes/vbox/CentOS8_Zabbix4.4/
vagrant up
```

After successful installation, you can visit urls on your host os which are mentioned below to see zabbix 4.4 dashboard

```
Zabbix - http://localhost:8080/zabbix
```

Default username **Admin**
Default password **zabbix**

