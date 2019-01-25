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