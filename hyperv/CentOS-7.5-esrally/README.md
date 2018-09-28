# es perfomance check
A vagrant box that provisions ElasticSearch esrally on CentOS 7.5 

## Prerequisites
1. Enable Hyper-V
2. Install [Vagrant](https://vagrantup.com/)

## Getting started
1. Clone this repository `git clone https://github.com/krivegasa/vagrant-boxes`
2. Change into the desired version folder 

## Run
vagrant up

## Bench
vagrant ssh

### Start local host benchmark:
   esrally --distribution-version=5.4.0
### Start remote host benchmark:
   esrally --track=pmc --target-hosts=10.5.5.10:9200,10.5.5.11:9200,10.5.5.12:9200 --pipeline=benchmark-only
