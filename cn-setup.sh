#!/bin/bash
set -x

yum -y install nfs-utils

mount -a

chmod 777 /tmp
chmod 777 /global
chmod 777 /remote
chmod 777 /u

adminUserName=${1}
user1=${2}
user1_UID=${3}
user2_sshkey=${4}
user2=${5}
user2_UID=${6}
user2_sshkey=${7}

#disable_selinux
sed -i 's/^SELINUX=.*/SELINUX=disabled/I' /etc/selinux/config
setenforce 0

# Disable tty requirement for sudo
sed -i 's/^Defaults[ ]*requiretty/# Defaults requiretty/g' /etc/sudoers

# Enable Admin User to sudo without a password
echo "$adminUserName ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

PROTEUS_GROUP=proteus
PROTEUS_GID=7007

groupadd -g $PROTEUS_GID $PROTEUS_GROUP


echo "$user1 ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo "$user2 ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

useradd -g $PROTEUS_GROUP -m -d /home/$user1 -s /bin/bash -u $user1_UID $user1
useradd -g $PROTEUS_GROUP -m -d /home/$user2 -s /bin/bash -u $user2_UID $user2
        
mkdir -p /home/$user1/.ssh
mkdir -p /home/$user2/.ssh

#ssh-keygen -t rsa -f /share/home/$HPC_USER/.ssh/id_rsa -q -P ""
        
echo "$user1_sshkey >> /home/$user1/.ssh/authorized_keys

echo "Host *" > /home/$user1/.ssh/config
echo "    StrictHostKeyChecking no" >> /home/$user1/.ssh/config
echo "    UserKnownHostsFile /dev/null" >> /home/$user1/.ssh/config
echo "    PasswordAuthentication no" >> /home/$user1/.ssh/config

chown -R $user1:$PROTEUS_GROUP /home/$user1

chmod 700 /home/$user1/.ssh
chmod 644 /home/$user1/.ssh/config
chmod 644 /home/$user1/.ssh/authorized_keys
chmod 600 /home/$user1/.ssh/id_rsa
chmod 644 /home/$user1/.ssh/id_rsa.pub


echo "$user2_sshkey >> /home/$user2/.ssh/authorized_keys

echo "Host *" > /home/$user2/.ssh/config
echo "    StrictHostKeyChecking no" >> /home/$user2/.ssh/config
echo "    UserKnownHostsFile /dev/null" >> /home/$user2/.ssh/config
echo "    PasswordAuthentication no" >> /home/$user2/.ssh/config

chown -R $user2:$PROTEUS_GROUP /home/$user2

chmod 700 /home/$user2/.ssh
chmod 644 /home/$user2/.ssh/config
chmod 644 /home/$user2/.ssh/authorized_keys
chmod 600 /home/$user2/.ssh/id_rsa
chmod 644 /home/$user2/.ssh/id_rsa.pub

