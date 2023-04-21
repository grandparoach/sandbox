#!/bin/bash
set -x

adminUserName=${1}
adminPassword=${2}
OSselection=${3}

if [ $OSselection -eq 'Rocky_8' ]
then
    #disable_selinux
    sed -i 's/^SELINUX=.*/SELINUX=disabled/I' /etc/selinux/config
    setenforce 0
fi

#prevent the inactive sessions from locking up
sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 3600/I' /etc/ssh/sshd_config
systemctl restart sshd

# Disable tty requirement for sudo
sed -i 's/^Defaults[ ]*requiretty/# Defaults requiretty/g' /etc/sudoers

# Enable Admin User to sudo without a password
echo "$adminUserName ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers



configure_ssh() {
    
if [ $OSselection -eq 'Rocky_8' ]
then
    yum -y install sshpass
else
    apt-get update
    apt-get -y install sshpass
fi
    ssh-keygen -t rsa -f /root/.ssh/id_rsa -q -P ''

    sshpass -p $adminPassword ssh-copy-id -i /home/$adminUserName/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 $adminUserName@head -p 22
    sshpass -p $adminPassword ssh-copy-id -i /home/$adminUserName/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 $adminUserName@compute1 -p 22
    sshpass -p $adminPassword ssh-copy-id -i /home/$adminUserName/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 $adminUserName@compute2 -p 22
    sshpass -p $adminPassword ssh-copy-id -i /home/$adminUserName/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 $adminUserName@compute3 -p 22
    sshpass -p $adminPassword ssh-copy-id -i /home/$adminUserName/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 $adminUserName@compute4 -p 22
       
}

configure_ssh

if [ $OSselection -eq 'Rocky_8' ]
then
    yum -y update
fi
