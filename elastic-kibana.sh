#!/bin/bash
echo "#########################################"
echo "#       SCRIPT TO INSTALL JAVA          #"
echo "#      + ELASTICSEARCH + KIBANA         #"
echo "#########################################"
# install wget
echo "Install wget"
yum -y install wget

# download java
echo "Downloading java"
mkdir /usr/java
cd /usr/java
wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/11.0.2+9/f51449fcd52f4d52b93a989c5c56ed3c/jdk-11.0.2_linux-x64_bin.rpm
rpm -ivh jdk-11.0.2_linux-x64_bin.rpm
rm -rf jdk-11.0.2_linux-x64_bin.rpm
export JAVA_HOME=/usr/java/jdk-11.0.2/
export JAVA_PATH=$JAVA_HOME
export PATH=$PATH:$JAVA_HOME/bin

#  import GPG key for elasticsearch
echo "Import GPG key for elasticsearch"
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

#  make elasticsearch.repo

echo "Making elasticsearch.repo"
if [ ! -f /etc/yum.repos.d/elasticsearch.repo ]; then
cat <<EOF > /etc/yum.repos.d/elasticsearch.repo
[elasticsearch-6.x]
name=Elasticsearch repository for 6.x packages
baseurl=https://artifacts.elastic.co/packages/6.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

else
    echo "File found, continue"
fi

#  install elasticsearch
echo "Installing elasticsearch"
yum -y install elasticsearch

# configure elasticsearch
echo "configuring elasticsearch to be visible"
cat <<EOF >> /etc/elasticsearch/elasticsearch.yml
network.host: 0.0.0.0
transport.host: localhost
http.port: 9200
transport.tcp.port: 9300
cluster.name: elasticsearch
node.name: "node1"
node.master: true
node.data: true
EOF

# disable firewalld, this is optional, but if you not disable it, you must configure it
systemctl stop firewalld
systemctl disable firewalld


# enable elasticsearch on start
echo "Enabling elasticsearch on start"
/bin/systemctl daemon-reload
/bin/systemctl enable elasticsearch.service
/bin/systemctl start elasticsearch.service

#  import GPG key for kibana
echo "Import GPG key for kibana"
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

#  make kibana.repo
echo "Making kibana.repo"
if [ ! -f /etc/yum.repos.d/kibana.repo ]; then
cat <<EOF > /etc/yum.repos.d/kibana.repo
[kibana-6.x]
name=Kibana repository for 6.x packages
baseurl=https://artifacts.elastic.co/packages/6.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md

else
    echo "File found, continue"
fi

#  install kibana
echo "Installing kibana"
yum -y install kibana

# configure kibana
echo "Configuring kibana to be visible"
cat <<EOF >> /etc/kibana/kibana.yml
server.port: 5601
server.host: "0.0.0.0"      #default is localhost
server.name: "kibana"
elasticsearch.url: "http://localhost:9200"
EOF

# enable kibana on start
echo "Enabling kibana on start"
/bin/systemctl daemon-reload
/bin/systemctl enable kibana.service
/bin/systemctl start kibana.service

exit 0
