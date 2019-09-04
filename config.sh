#!/bin/bash
set -x

adminUserName=${1}
adminPassword=${2}

#disable_selinux
sed -i 's/^SELINUX=.*/SELINUX=disabled/I' /etc/selinux/config
setenforce 0

#set a password for root
echo "root:$adminPassword" | chpasswd

sleep 30

# Disable tty requirement for sudo
sed -i 's/^Defaults[ ]*requiretty/# Defaults requiretty/g' /etc/sudoers

# Enable Admin User to sudo without a password
echo "$adminUserName ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

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
