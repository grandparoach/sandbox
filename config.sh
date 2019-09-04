#!/bin/bash
set -x

adminUserName=${1}
adminPassword=${2}
clusterprefix=${3}
nodecount=${4}

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



format_disks() {
mkdir /mnt/resource/opt
cp /opt/* /mnt/resource/opt   
fdisk /dev/sdc << EOF
n
p
1
t
83
w
EOF

mkfs -t ext4 /dev/sdc1

echo "/dev/sdc1 /opt ext4 defaults,nofail 0 2" >> /etc/fstab

mount -a
cp /mnt/resource/opt/* /opt

}


configure_ssh() {
    
    yum -y install sshpass
    ssh-keygen -t rsa -f /root/.ssh/id_rsa -q -P ''
    index=0    
    while [ $index -lt $(($nodecount)) ]; do

        sshpass -p $adminPassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 root@${clusterprefix}00000${index} -p 22
        let index++
    done
    
}

format_disks
configure_ssh
