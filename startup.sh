#!/bin/bash
set -x

adminUserName=${1}
adminPassword=${2}

#disable_selinux
sed -i 's/^SELINUX=.*/SELINUX=disabled/I' /etc/selinux/config
setenforce 0

#prevent the inactive sessions from locking up
sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 360/I' /etc/ssh/sshd_config
systemctl restart sshd

#set a password for root
#echo "root:$adminPassword" | chpasswd

#sleep 60

# Disable tty requirement for sudo
sed -i 's/^Defaults[ ]*requiretty/# Defaults requiretty/g' /etc/sudoers

# Enable Admin User to sudo without a password
echo "$adminUserName ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

configure_ssh() {
    
    yum -y install sshpass
    runuser -u $adminUserName -- ssh-keygen -t rsa -f /home/$adminUserName/.ssh/id_rsa -q -P ''

    runuser -u $adminUserName -- sshpass -p $adminPassword ssh-copy-id -i /home/$adminUserName/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 $adminUserName@head -p 22
    runuser -u $adminUserName -- sshpass -p $adminPassword ssh-copy-id -i /home/$adminUserName/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 $adminUserName@compute1 -p 22
    runuser -u $adminUserName -- sshpass -p $adminPassword ssh-copy-id -i /home/$adminUserName/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 $adminUserName@compute2 -p 22
    runuser -u $adminUserName -- sshpass -p $adminPassword ssh-copy-id -i /home/$adminUserName/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 $adminUserName@compute3 -p 22
    runuser -u $adminUserName -- sshpass -p $adminPassword ssh-copy-id -i /home/$adminUserName/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 $adminUserName@compute4 -p 22
    
}

configure_ssh
yum -y update
