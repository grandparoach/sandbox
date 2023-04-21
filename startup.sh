#!/bin/bash
export TERM=Teletype
set -x

adminUserName=${1}
adminPassword=${2}
OSselection=${3}

if [ $OSselection = 'Rocky_8' ]
then
    #disable_selinux
    sed -i 's/^SELINUX=.*/SELINUX=disabled/I' /etc/selinux/config
    setenforce 0
fi

#set a password for root
echo "root:$adminPassword" | chpasswd

sleep 30

#prevent the inactive sessions from locking up
sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 3600/I' /etc/ssh/sshd_config

#Allow root login
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/I' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/I' /etc/ssh/sshd_config
systemctl restart sshd

# Disable tty requirement for sudo
sed -i 's/^Defaults[ ]*requiretty/# Defaults requiretty/g' /etc/sudoers

# Enable Admin User to sudo without a password
echo "$adminUserName ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers



configure_ssh() {
    
if [ $OSselection = 'Rocky_8' ]
then
    yum install -y sshpass
else
    apt-get -y update
    apt-get install -y sshpass
fi
    
    ssh-keygen -t rsa -f /root/.ssh/id_rsa -q -P ''

    runuser -u root -- sshpass -p $adminPassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 root@head -p 22
    runuser -u root -- sshpass -p $adminPassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 root@compute1 -p 22
    runuser -u root -- sshpass -p $adminPassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 root@compute2 -p 22
    runuser -u root -- sshpass -p $adminPassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 root@compute3 -p 22
    runuser -u root -- sshpass -p $adminPassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 root@compute4 -p 22
    
    
    runuser -u $adminUserName -- ssh-keygen -t rsa -f /home/$adminUserName/.ssh/id_rsa -q -P ''

    runuser -u $adminUserName -- sshpass -p $adminPassword ssh-copy-id -i /home/$adminUserName/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 $adminUserName@head -p 22
    runuser -u $adminUserName -- sshpass -p $adminPassword ssh-copy-id -i /home/$adminUserName/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 $adminUserName@compute1 -p 22
    runuser -u $adminUserName -- sshpass -p $adminPassword ssh-copy-id -i /home/$adminUserName/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 $adminUserName@compute2 -p 22
    runuser -u $adminUserName -- sshpass -p $adminPassword ssh-copy-id -i /home/$adminUserName/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 $adminUserName@compute3 -p 22
    runuser -u $adminUserName -- sshpass -p $adminPassword ssh-copy-id -i /home/$adminUserName/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 $adminUserName@compute4 -p 22
    
}

configure_ssh

if [ $OSselection = 'Rocky_8' ]
then
    yum -y update
fi
