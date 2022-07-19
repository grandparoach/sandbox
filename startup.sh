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

HPC_UID=7007
HPC_GROUP=hpc
HPC_GID=7007

groupadd -g $HPC_GID $HPC_GROUP

mkdir -p /share/home

yum -y install nfs-utils

if [ `hostname` == "head" ];
then

echo "/share/home   *(rw,async)" >> /etc/exports
systemctl enable rpcbind || echo "Already enabled"
systemctl enable nfs-server || echo "Already enabled"
systemctl start rpcbind || echo "Already enabled"
systemctl start nfs-server || echo "Already enabled"
exportfs
exportfs -a
exportfs 

for HPC_USER in kara tim bob mary rae david joe alice
    do
        echo "$HPC_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
        useradd -g $HPC_GROUP -m -d /share/home/$HPC_USER -s /bin/bash -u $HPC_UID $HPC_USER
        
        mkdir -p /share/home/$HPC_USER/.ssh
        ssh-keygen -t rsa -f /share/home/$HPC_USER/.ssh/id_rsa -q -P ""
        cat /share/home/$HPC_USER/.ssh/id_rsa.pub >> /share/home/$HPC_USER/.ssh/authorized_keys

        echo "Host *" > /share/home/$HPC_USER/.ssh/config
	    echo "    StrictHostKeyChecking no" >> /share/home/$HPC_USER/.ssh/config
	    echo "    UserKnownHostsFile /dev/null" >> /share/home/$HPC_USER/.ssh/config
	    echo "    PasswordAuthentication no" >> /share/home/$HPC_USER/.ssh/config

        # Fix .ssh folder ownership
	    chown -R $HPC_USER:$HPC_GROUP /share/home/$HPC_USER

	    # Fix permissions
	    chmod 700 /share/home/$HPC_USER/.ssh
	    chmod 644 /share/home/$HPC_USER/.ssh/config
	    chmod 644 /share/home/$HPC_USER/.ssh/authorized_keys
	    chmod 600 /share/home/$HPC_USER/.ssh/id_rsa
	    chmod 644 /share/home/$HPC_USER/.ssh/id_rsa.pub

        let HPC_UID=$HPC_UID+1

    done

else
# wait for NFS Server to get configured
sleep 30

echo "head:/share/home /share/home nfs4   rw,auto,_netdev 0 0" >> /etc/fstab
mount -a
mount

for HPC_USER in kara tim bob mary rae david joe alice
    do
        echo "$HPC_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
        
        useradd -g $HPC_GROUP -d /share/home/$HPC_USER -s /bin/bash -u $HPC_UID $HPC_USER
        
        let HPC_UID=$HPC_UID+1

    done

fi

configure_ssh() {
    

    yum -y install sshpass
    ssh-keygen -t rsa -f /root/.ssh/id_rsa -q -P ''

    sshpass -p $adminPassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 root@head -p 22
    sshpass -p $adminPassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 root@compute1 -p 22
    sshpass -p $adminPassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 root@compute2 -p 22
    sshpass -p $adminPassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 root@compute3 -p 22
    sshpass -p $adminPassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 root@storage1 -p 22
    sshpass -p $adminPassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 root@storage2 -p 22
    sshpass -p $adminPassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 root@storage3 -p 22
    sshpass -p $adminPassword ssh-copy-id -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 root@storage4 -p 22
    
    
}

configure_ssh
