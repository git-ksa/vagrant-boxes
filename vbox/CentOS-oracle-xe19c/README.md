# oracle-xe19c-vagrant
A vagrant box that provisions Oracle Database 19c Express Edition for Linux x64 automatically, using Vagrant, an Centos 7 box and a shell script.

## Prerequisites

* [Vagrant](https://www.vagrantup.com/intro/getting-started/install.html) - Vagrant manages virtual machines 
* [Virtualbox](https://www.virtualbox.org/wiki/Linux_Downloads) - Vagrant depends on virtualbox to run virtual machines 

## Getting started
1. Clone this repository `git clone https://github.com/krivegasa/vagrant-boxes`
2. Change into the desired version folder
 `cd ./vagrant-boxes/vbox/CentOS-oracle-xe19c`
3. Download the installation file Oracle Database 19c Express Edition for Linux x64 Download (2,574,155,124 bytes) CentOS-oracle-xe19c/oracle-database-ee-19c-1.0-1.x86_64.rpm:
[https://www.oracle.com/technetwork/database/enterprise-edition/downloads/oracle19c-linux-5462157.html](https://www.oracle.com/technetwork/database/enterprise-edition/downloads/oracle19c-linux-5462157.html)
  `/vagrant-boxes/vbox/CentOS-oracle-xe19c/oracle-database-ee-19c-1.0-1.x86_64.rpm`
4. Run `vagrant up`
5. Connect to the database.
6. You can shut down the box via the usual `vagrant halt` and the start it up again via `vagrant up`.

## Connecting to Oracle
* Hostname: `localhost`
* Port: `1521`
* SID: `XE`
* OEM port: `5500`
* SYS/SYSTEM password: `GetStarted19c`

## Other info

* If you need to, you can connect to the machine via `vagrant ssh`.
* You can `sudo su - oracle` to switch to the oracle user.
* The Oracle installation path is `/opt/oracle/` by default.
* On the guest OS, the directory `/vagrant` is a shared folder and maps to wherever you have this file checked out.
