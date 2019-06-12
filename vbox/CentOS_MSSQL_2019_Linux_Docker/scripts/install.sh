echo 'Install the client packages:'
yum install mc telnet net-tools htop docker -y
echo 'Enable docker'
systemctl enable docker
systemctl start docker
echo 'Starting MSSQL 2019'
docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=P@ssw0rd' -p 1433:1433 --name sql2019 -d mcr.microsoft.com/mssql/server:2019-CTP3.0-ubuntu


