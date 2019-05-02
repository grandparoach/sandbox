#!/bin/bash
set -x

#disable_selinux
sed -i 's/^SELINUX=.*/SELINUX=disabled/I' /etc/selinux/config
setenforce 0

adminPassword=${1}
#set a password for root
echo "root:$adminPassword" | chpasswd

#give all the nodes time to complete spinning up
sleep 60

configure_ssh() {
    

    yum -y install sshpass
    ssh-keygen -t rsa -f /root/.ssh/id_rsa -q -P ''

    sshpass -p $adminPassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 root@Login -p 22
    sshpass -p $adminPassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 root@Compute-0 -p 22
    sshpass -p $adminPassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 root@Compute-1 -p 22
    sshpass -p $adminPassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 root@Storage-0 -p 22
    sshpass -p $adminPassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 root@Storage-1 -p 22
    sshpass -p $adminPassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 root@Storage-2 -p 22
    sshpass -p $adminPassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 root@Storage-3 -p 22
    
    
}

configure_ssh
