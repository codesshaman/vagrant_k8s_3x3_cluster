# -*- mode: ruby -*-
# vi: set ft=ruby :

IP = 9

NUM_MASTERS = 1
NUM_WORKERS = 1

IP_ADDRESS = "10.10.10"

MASTER_NAME = "master_of_puppets_"
WORKER_NAME = "puppet_"

MASTER_ALIAS = "master"
WORKER_ALIAS = "worker"

MASTERS_LIST = ""
WORKERS_LIST = ""

MASTERS_IP = ""
WORKERS_IP = ""
i = 0
c = 9
while i < NUM_MASTERS
    c += 1
    MASTERS_IP = MASTERS_IP + "#{IP_ADDRESS}.#{c}" + " "
    i += 1
    MASTERS_LIST = MASTERS_LIST + "#{MASTER_ALIAS}#{i}" + " "
end
i = 0
while i < NUM_WORKERS
    c += 1
    WORKERS_IP = WORKERS_IP + "#{IP_ADDRESS}.#{c}" + " "
    i += 1
    WORKERS_LIST = WORKERS_LIST + "#{WORKER_ALIAS}#{i}" + " "
end
WORKER_PORT = 9090
MASTER_PORT = 8080

MASTER_CPU = "3"
MASTER_MEMORY = "3072"

SLAVE_CPU = "2"
SLAVE_MEMORY = "2048"

MAC_LIST_M = [
    '080027b893a3',
    '080027a20ad1',
    '08002740d567',
    '0800277489c4',
    '0800278a6977',
    '080027928568',
    '08002705b7d3',
    '080027b176c1',
    '0800278bc27b'
]

MAC_LIST_W = [
    '080027301f31',
    '08002708fd26',
    '080027a3e6a7',
    '0800278b0c4c',
    '080027836753',
    '080027ec85cc',
    '080027149319',
    '08002778228d',
    '080027598ca6'
]

# 10.10.0.2 – 10.255.255.255
# 172.16.0.2 – 172.31.255.255
# 192.168.0.0 – 192.168.255.255

key = File.read("#{Dir.home}/.ssh/id_rsa.pub")

Vagrant.configure('2') do |config|
    (1..NUM_MASTERS).each do |n|
        config.vm.define "master#{n}" do |master|
            IP += 1
            master.vm.box = 'bento/debian-11.5'
            master.vm.hostname = "master#{n}"
            master.vm.network "forwarded_port",
            guest: MASTER_PORT + n, host: MASTER_PORT + n
            master.vm.network 'private_network', 
            ip: "#{IP_ADDRESS}.#{IP}", subnet: "255.255.255.0"
            master.vm.provision "copy ssh public key", type: "shell",
            inline: "echo \"#{key}\" >> /home/vagrant/.ssh/authorized_keys"
            master.vm.provision "shell",
            privileged: true, path: "master_node_setup.sh",
            args: [MASTERS_LIST, MASTERS_IP, WORKERS_LIST, WORKERS_IP]
            master.vm.provision "shell", inline: "sudo swapoff -a"
            master.vm.provision "shell",
            inline: "sed -i 's!/dev/mapper/debian--11--vg-swap!#/dev/mapper/debian--11--vg-swap!1' /etc/fstab"
            master.vm.provider 'virtualbox' do |v|
                v.customize ["modifyvm", :id,
                "--macaddress1", "#{MAC_LIST_M[n]}"]
                v.name = "#{MASTER_NAME}#{n}"
                v.memory = MASTER_MEMORY
                v.cpus = MASTER_CPU
            end
        end
    end

    (1..NUM_WORKERS).each do |n|
        config.vm.define "worker#{n}" do |worker|
            IP += 1
            worker.vm.box = 'bento/debian-11.5'
            worker.vm.hostname = "worker#{n}"
            worker.vm.network "forwarded_port",
            guest: WORKER_PORT + n, host: WORKER_PORT + n
            worker.vm.network 'private_network', 
            ip: "#{IP_ADDRESS}.#{IP}", subnet: "255.255.255.0"
            worker.vm.provision "copy ssh public key", type: "shell",
            inline: "echo \"#{key}\" >> /home/vagrant/.ssh/authorized_keys"
            worker.vm.provision "shell", 
            privileged: true, path: "worker_node_setup.sh",
            args: [MASTERS_LIST, MASTERS_IP,WORKERS_LIST, WORKERS_IP]
            worker.vm.provision "shell", inline: "sudo swapoff -a"
            worker.vm.provision "shell",
            inline: "sed -i 's!/dev/mapper/debian--11--vg-swap!#/dev/mapper/debian--11--vg-swap!1' /etc/fstab"
            worker.vm.provider 'virtualbox' do |v|
                v.customize ["modifyvm", :id,
                "--macaddress1", "#{MAC_LIST_W[n]}"]
                v.name = "#{WORKER_NAME}#{n}"
                v.memory = SLAVE_MEMORY
                v.cpus = SLAVE_CPU
            end
        end
    end
end
