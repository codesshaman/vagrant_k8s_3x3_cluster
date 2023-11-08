#!/bin/bash
no='\033[0m'		# Color Reset
ok='\033[32;01m'    # Green Ok
err='\033[31;01m'	# Error red
warn='\033[1;33m'   # Yellow
blue='\033[1;34m'   # Blue
purp='\033[1;35m'   # Purple
cyan='\033[1;36m'   # Cyan
white='\033[1;37m'  # White

echo -e "${warn}[Node Exporter]${no} : ${cyan}Загрузка...${no}"
wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
echo -e "${warn}[Node Exporter]${no} : ${ok}...успешно загружено${no}"

echo -e "${warn}[Node Exporter]${no} : ${cyan}Установка...${no}"
tar xvfz node_exporter-*.linux-amd64.tar.gz
cd node_exporter-*.*-amd64
sudo mv node_exporter /usr/bin/

echo -e "${warn}[Node Exporter]${no} : ${cyan}Создание пользователя...${no}"
sudo useradd -r -M -s /bin/false node_exporter
sudo chown node_exporter:node_exporter /usr/bin/node_exporter

echo -e "${warn}[Node Exporter]${no} : ${cyan}Создание системного юнита...${no}"
{   echo '[Unit]'; \
    echo 'Description=Prometheus Node Exporter'; \
    echo '[Service]'; \
    echo 'User=node_exporter'; \
    echo 'Group=node_exporter'; \
    echo 'Type=simple'; \
    echo 'ExecStart=/usr/bin/node_exporter'; \
    echo '[Install]'; \
    echo 'WantedBy=multi-user.target'; \
} | tee /etc/systemd/system/node_exporter.service;

echo -e "${warn}[Node Exporter]${no} : ${cyan}Перезагрузка юнита...${no}"
sudo systemctl daemon-reload
echo -e "${warn}[Node Exporter]${no} : ${cyan}Запуск node exporter...${no}"
sudo systemctl enable --now node_exporter
sudo systemctl status node_exporter
echo -e "${ok}Node exporter has been setup succefully!${no}"

echo -e "${warn}[k8s installer]${no} ${cyan}Установка необходимого софта${no}"
apt-get update -y && \
apt-get install -y \
    git \
    htop \
    wget \
    curl \
    make \
    tmux \
    ethtool \
    python3-pip \
    libnss3-tools
# pip3 install ansible
su - vagrant -c 'pip freeze >> /home/vagrant/requirements.txt'

echo -e "${warn}[k8s installer]${no} ${cyan}Скачивание kubespray${no}"
git clone https://github.com/kubernetes-sigs/kubespray.git /root/kubespray
cd /root/kubespray
pip install -r requirements.txt
git checkout release-2.21
cp -rf inventory/sample inventory/my_cluster
rm inventory/my_cluster/inventory.ini
cat > /root/kubespray/inventory/my_cluster/inventory.ini << _EOF_
[all]
ingress ansible_host=10.10.10.10 ip=10.10.10.10 etcd_member_name=etcd0
master1 ansible_host=10.10.10.11 ip=10.10.10.11 etcd_member_name=etcd1
master2 ansible_host=10.10.10.12 ip=10.10.10.12 etcd_member_name=etcd2
master3 ansible_host=10.10.10.13 ip=10.10.10.13 etcd_member_name=etcd3
worker1 ansible_host=10.10.10.14 ip=10.10.10.14 etcd_member_name=etcd4
worker2 ansible_host=10.10.10.15 ip=10.10.10.15 etcd_member_name=etcd5
worker3 ansible_host=10.10.10.16 ip=10.10.10.16 etcd_member_name=etcd6

[kube_control_plane]
master1
master2
master3

[etcd]
master1
master2
master3

[kube_node]
worker1
worker2
worker3

[kube-ingress]
ingress

[calico_rr]

[k8s_cluster:children]
kube_control_plane
kube-ingress
kube_node
calico_rr
_EOF_
sed -i 's!helm_enabled: false!helm_enabled: true!1' \
/root/kubespray/inventory/my_cluster/group_vars/k8s_cluster/addons.yml
sed -i 's!registry_enabled: false!registry_enabled: true!1' \
/root/kubespray/inventory/my_cluster/group_vars/k8s_cluster/addons.yml
sed -i 's!metrics_server_enabled: false!metrics_server_enabled: true!1' \
/root/kubespray/inventory/my_cluster/group_vars/k8s_cluster/addons.yml
sed -i 's!local_volume_provisioner_enabled: false!local_volume_provisioner_enabled: true!1' \
/root/kubespray/inventory/my_cluster/group_vars/k8s_cluster/addons.yml
cd /root

echo -e "${warn}[k8s installer]${no} ${cyan}Добавление серверов в hosts-файлы${no}"
echo "#!/bin/bash" >> /home/vagrant/ping.sh
str1=$2
if [[ "${str1: -1}" = " " ]]; then
  str1="${str1%?}"
fi
str2=$4
if [[ "${str2: -1}" = " " ]]; then
  str2="${str2%?}"
fi
strm=$1
if [[ "${strm: -1}" = " " ]]; then
  strm="${strm%?}"
fi
strw=$3
if [[ "${strw: -1}" = " " ]]; then
  strw="${strw%?}"
fi
spce=" "
dmin=".loc"
mapfile -d' ' -t ipsm <<< "$str1"
mapfile -d' ' -t ipsw <<< "$str2"
mapfile -d' ' -t nmsm <<< "$strm"
mapfile -d' ' -t nmsw <<< "$strw"
echo -e "${warn}[k8s installer]${no} ${cyan}Создание key_copy.sh ${no}"
cat > /home/vagrant/key_copy.sh << _EOF_
#!/bin/bash
ssh-keygen

_EOF_
chown vagrant:vagrant /home/vagrant/key_copy.sh
chmod +x /home/vagrant/key_copy.sh
echo -e "${warn}[k8s installer]${no} ${cyan}Создание /etc/hosts и ping.sh ${no}"
count=0
for ip in "${ipsm[@]}"
do
  # Добавление данных в /etc/hosts
  string="$ip ${nmsm[count]} ${nmsm[count]}.loc"
  display=$(echo "$string" | tr '\n' '^' | tr -s " " | sed 's/\^//g')
  echo "$display" >> /etc/hosts
  # Добавление данных в ping.sh
  string="ping ${ip} -c 2"
  display=$(echo "$string" | tr '\n' ' ')
  echo "$display" >> /home/vagrant/ping.sh
  string="ping ${nmsm[count]} -c 2"
  display=$(echo "$string" | tr '\n' "^" | sed 's/\^//g')
  echo "$display" >> /home/vagrant/ping.sh
  string="ping ${nmsm[count]}.loc -c 2"
  display=$(echo "$string" | tr '\n' "^" | sed 's/\^//g')
  echo "$display" >> /home/vagrant/ping.sh
  # Добавление данных в key_copy.sh
  echo "ssh-copy-id ${nmsm[count]}" >> /home/vagrant/key_copy.sh
  ((count++))
done
count=0
for ip in "${ipsw[@]}"
do
  # Добавление данных в /etc/hosts
  string="$ip ${nmsw[count]} ${nmsw[count]}.loc"
  display=$(echo "$string" | tr '\n' '^' | tr -s " " | sed 's/\^//g')
  echo "$display" >> /etc/hosts
  # Добавление данных в ping.sh
  string="ping ${ip} -c 2"
  display=$(echo "$string" | tr '\n' ' ')
  echo "$display" >> /home/vagrant/ping.sh
  string="ping ${nmsw[count]} -c 2"
  display=$(echo "$string" | tr '\n' "^" | sed 's/\^//g')
  echo "$display" >> /home/vagrant/ping.sh
  string="ping ${nmsw[count]}.loc -c 2"
  display=$(echo "$string" | tr '\n' "^" | sed 's/\^//g')
  echo "$display" >> /home/vagrant/ping.sh
  # Добавление данных в key_copy.sh
  echo "ssh-copy-id ${nmsw[count]}" >> /home/vagrant/key_copy.sh
  ((count++))
done
# Добавление ingress-контроллера:
str="${6} ${5} ${5}.loc"
# disp=$(echo "$str" | tr '\n' '^' | tr -s " " | sed 's/\^//g')
echo "$str" >> /etc/hosts
echo "ping ${5} -c 2" >> /home/vagrant/ping.sh
echo "ssh-copy-id ${5}" >> /home/vagrant/key_copy.sh
# Добавление адресов для проверки доступа в интернет
echo "ping 8.8.8.8 -c 2" >> /home/vagrant/ping.sh
echo "ping ya.ru -c 2" >> /home/vagrant/ping.sh
chown vagrant:vagrant /home/vagrant/ping.sh
chmod +x /home/vagrant/ping.sh
echo -e "${warn}[k8s installer]${no} ${cyan}Создание check.sh ${no}"
cat > /home/vagrant/check.sh << _EOF_
#!/bin/bash
echo "Имя хоста (должно отличаться)"
hostname
echo "MAC-адрес (должен отличаться)"
ip link | grep link/ether
echo "Идентификатор VM (должен отличаться)"
sudo dmidecode -s system-uuid
echo "Адрес шлюза (должен быть одинаковым)"
netstat -rn | grep ^0.0.0.0 | awk '{print \$2}'
_EOF_
chown vagrant:vagrant /home/vagrant/check.sh
chmod +x /home/vagrant/check.sh
echo -e "${warn}[k8s installer]${no} ${cyan}Разрешаю логин под root${no}"
sed -i 's!#PermitRootLogin prohibit-password!PermitRootLogin yes!g' /etc/ssh/sshd_config
service sshd restart
echo -e "${warn}[k8s installer]${no} ${cyan}Задаю пароль root${no}"
echo "root:root" | chpasswd