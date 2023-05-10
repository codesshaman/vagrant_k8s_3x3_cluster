# -*- mode: ruby -*-
# vi: set ft=ruby :

IP = 9

NUM_MASTERS = 3
NUM_WORKERS = 3

WORKER_PORT = 9090
MASTER_PORT = 8080

MASTER_CPU = "3"
MASTER_MEMORY = "3072"

SLAVE_CPU = "2"
SLAVE_MEMORY = "2048"

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
            master.vm.network 'private_network', ip: "10.10.10.#{IP}"
            puts "master#{n} address: 10.10.10.#{IP}"
            master.vm.provider 'virtualbox' do |v|
                v.name = "master_of_puppets_#{n}"
                v.memory = MASTER_MEMORY
                v.cpus = MASTER_CPU
            end
            master.vm.provision "copy ssh public key", type: "shell",
            inline: "echo \"#{key}\" >> /home/vagrant/.ssh/authorized_keys"
            # master.vm.provision "shell", privileged: true,
            # path: "slave_node_setup.sh",
            # args: [MASTER_NODE_IP, WORKERS_IP]
        end
    end

    (1..NUM_WORKERS).each do |n|
        config.vm.define "worker#{n}" do |worker|
            IP += 1
            worker.vm.box = 'bento/debian-11.5'
            worker.vm.hostname = "worker#{n}"
            worker.vm.network "forwarded_port",
            guest: WORKER_PORT + n, host: WORKER_PORT + n
            worker.vm.network 'private_network', ip: "10.10.10.#{IP}"
            puts "worker#{n} address: 10.10.10.#{IP}"
            worker.vm.provider 'virtualbox' do |v|
                v.name = "puppet_#{n}"
                v.memory = SLAVE_MEMORY
                v.cpus = SLAVE_CPU
            end
            worker.vm.provision "copy ssh public key", type: "shell",
            inline: "echo \"#{key}\" >> /home/vagrant/.ssh/authorized_keys"
            # worker.vm.provision "shell", privileged: true,
            # path: "slave_node_setup.sh",
            # args: [MASTER_NODE_IP, "10.10.10.10"]
        end
    end
end
