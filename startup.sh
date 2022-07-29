#!/bin/bash
set -x

adminUserName=${1}
adminPassword=${2}

#disable_selinux
sed -i 's/^SELINUX=.*/SELINUX=disabled/I' /etc/selinux/config
setenforce 0

#set a password for root
#echo "root:$adminPassword" | chpasswd

sleep 60

# Disable tty requirement for sudo
sed -i 's/^Defaults[ ]*requiretty/# Defaults requiretty/g' /etc/sudoers

# Enable Admin User to sudo without a password
echo "$adminUserName ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

configure_ssh() {
    
    yum -y install sshpass
    ssh-keygen -t rsa -f /home/$adminUserName/.ssh/id_rsa -q -P ''

    sshpass -p $adminPassword ssh-copy-id -i /home/$adminUserName/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 $adminUserName@head -p 22
    sshpass -p $adminPassword ssh-copy-id -i /home/$adminUserName/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 $adminUserName@compute1 -p 22
    sshpass -p $adminPassword ssh-copy-id -i /home/$adminUserName/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 $adminUserName@compute2 -p 22
    sshpass -p $adminPassword ssh-copy-id -i /home/$adminUserName/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 $adminUserName@compute3 -p 22
    sshpass -p $adminPassword ssh-copy-id -i /home/$adminUserName/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 $adminUserName@compute4 -p 22
    
}

configure_ssh
yum -y update
