#!/usr/bin/env bash
sudo apt-get update
sudo apt-get wget
# create downloads directory so that we can download all the packages
# which are required during provisioning process
mkdir /home/vagrant/Downloads
cd /home/vagrant/Downloads

# download prometheus installation files
wget https://github.com/prometheus/prometheus/releases/download/v1.6.2/prometheus-1.6.2.linux-amd64.tar.gz

# create directory for prometheus installation files
# so that we can extrac all the files into it
mkdir -p /home/vagrant/Prometheus/server
cd /home/vagrant/Prometheus/server

# Extract files
tar -xvzf /home/vagrant/Downloads/prometheus-1.6.2.linux-amd64.tar.gz

cd prometheus-1.6.2.linux-amd64

# check prometheus version
./prometheus -version

# create directory for node_exporter which can be used to send ubuntu metrics to the prometheus server
mkdir -p /home/vagrant/Prometheus/node_exporter
cd /home/vagrant/Prometheus/node_exporter

# download node_exporter
wget https://github.com/prometheus/node_exporter/releases/download/v0.14.0/node_exporter-0.14.0.linux-amd64.tar.gz -O /home/vagrant/Downloads/node_exporter-0.14.0.linux-amd64.tar.gz

# extract node_exporter
tar -xvzf /home/vagrant/Downloads/node_exporter-0.14.0.linux-amd64.tar.gz

# create a symbolic link of node_exporter
sudo ln -s /home/vagrant/Prometheus/node_exporter/node_exporter-0.14.0.linux-amd64/node_exporter /usr/bin

# edit node_exporter configuration file and add configuration so that it will automatically start in next boot
cat <<EOF > /etc/init/node_exporter.conf
# Run node_exporter-0.14.0.linux-amd64

start on startup

script
   /usr/bin/node_exporter
end script
EOF

# prepare service of node_exporter
sudo useradd node_exporter -s /sbin/nologin

cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter

[Service]
User=node_exporter
EnvironmentFile=/etc/sysconfig/node_exporter
ExecStart=/usr/bin/node_exporter $OPTIONS

[Install]
WantedBy=multi-user.target
EOF

sudo mkdir -p /etc/sysconfig
sudo cat <<EOF > /etc/sysconfig/node_exporter
OPTIONS="--collector.textfile.directory /var/lib/node_exporter/textfile_collector"
EOF

# start service of node_exporter

sudo systemctl daemon-reload
sudo systemctl enable node_exporter

sudo systemctl start node_exporter

curl http://localhost:9100/metrics


cd /home/vagrant/Prometheus/server/prometheus-1.6.2.linux-amd64/

# edit prometheus configuration file which will pull metrics from node_exporter
# every 15 seconds time interval
cat <<EOF > prometheus.yml
global:
  scrape_interval:     15s # By default, scrape targets every 15 seconds.

  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
    monitor: 'codelab-monitor'

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'node-prometheus'
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'prometheus'
    scrape_interval: 10s
    static_configs:
      - targets: ['localhost:9090']
EOF

# start prometheus
nohup ./prometheus > prometheus.log 2>&1 &

sudo apt-get install -y adduser libfontconfig

# download grafana 4.2
# wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_4.2.0_amd64.deb -O /home/vagrant/Downloads/grafana_4.2.0_amd64.deb
# install grafana 
# sudo dpkg -i /home/vagrant/Downloads/grafana_4.2.0_amd64.deb

# download grafana 5.3.1
wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_5.3.1_amd64.deb -O /home/vagrant/Downloads/grafana_5.3.1_amd64.deb
sudo dpkg -i /home/vagrant/Downloads/grafana_5.3.1_amd64.deb

# start grafana service 
sudo service grafana-server start

# run on every boot
sudo update-rc.d grafana-server defaults

echo "Prometheus:            http://host_ip:9090           http://localhost:9090"
echo "Node_exporter:         http://host_ip:9100/metrics   http://localhost:9100/metrics"
echo "Grafana (admin/admin): http://host_ip:3000           http://localhost:3000"
