#!/bin/bash
set -x

# format the d drive
fdisk /dev/sdd << EOF
n
p
1


p
w
EOF

# make the file system
mkfs -t xfs /dev/sdd1

# mount over /opt
echo "/dev/sdd1 /opt xfs defaults,nofail 0 2" >> /etc/fstab
    mount /dev/sdd1
