# -*- mode: ruby -*-
# vi: set ft=ruby :

IP = 9

NUM_MASTERS = 2
NUM_WORKERS = 2

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
puts MASTERS_IP
i = 0
while i < NUM_WORKERS
    c += 1
    WORKERS_IP = WORKERS_IP + "#{IP_ADDRESS}.#{c}" + " "
    i += 1
    WORKERS_LIST = WORKERS_LIST + "#{WORKER_ALIAS}#{i}" + " "
end
puts WORKERS_IP
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
            master.vm.network 'private_network', ip: "#{IP_ADDRESS}.#{IP}"
            puts "master#{n} address: #{IP_ADDRESS}.#{IP}"
            master.vm.provider 'virtualbox' do |v|
                v.name = "#{MASTER_NAME}#{n}"
                v.memory = MASTER_MEMORY
                v.cpus = MASTER_CPU
            end
            master.vm.provision "copy ssh public key", type: "shell",
            inline: "echo \"#{key}\" >> /home/vagrant/.ssh/authorized_keys"
            master.vm.provision "shell", privileged: true,
            path: "master_node_setup.sh",
            args: [MASTERS_LIST, MASTERS_IP, WORKERS_LIST, WORKERS_IP]
        end
    end

    (1..NUM_WORKERS).each do |n|
        config.vm.define "worker#{n}" do |worker|
            IP += 1
            worker.vm.box = 'bento/debian-11.5'
            worker.vm.hostname = "worker#{n}"
            worker.vm.network "forwarded_port",
            guest: WORKER_PORT + n, host: WORKER_PORT + n
            worker.vm.network 'private_network', ip: "#{IP_ADDRESS}.#{IP}"
            puts "worker#{n} address: #{IP_ADDRESS}.#{IP}"
            worker.vm.provider 'virtualbox' do |v|
                v.name = "#{WORKER_NAME}#{n}"
                v.memory = SLAVE_MEMORY
                v.cpus = SLAVE_CPU
            end
            worker.vm.provision "copy ssh public key", type: "shell",
            inline: "echo \"#{key}\" >> /home/vagrant/.ssh/authorized_keys"
            worker.vm.provision "shell", privileged: true,
            path: "worker_node_setup.sh",
            args: [MASTERS_LIST, MASTERS_IP, WORKERS_LIST, WORKERS_IP]
        end
    end
end
