#!/bin/bash
# DISK - main disk name (ex sda/vda/sdb)
# URL - link to RAW image file (.img.zip) at official site of Mikrotik
# NET_INTF - name of interface (ex enp0s5/eth0)

DISK=$(cat /proc/partitions | awk '(NR==3){print $4}') && \ 
URL='https://download.mikrotik.com/routeros/6.42.3/chr-6.42.3.img.zip' && \
NET_INTF=$(ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2;getline}') && \
wget $URL -O chr.img.zip   && \
gunzip -c chr.img.zip > chr.img  && \
mount -o loop,offset=33554944 chr.img /mnt && \
ADDRESS=`ip addr show $NET_INTF | grep global | cut -d' ' -f 6 | head -n 1` && \
GATEWAY=`ip route list | grep default | cut -d' ' -f 3` && \
echo "/ip address add address=$ADDRESS interface=[/interface ethernet find where name=ether1]/ip route add gateway=$GATEWAY" > /mnt/rw/autorun.scr && \
umount /mnt && \
echo u > /proc/sysrq-trigger && \
dd if=chr.img of=/dev/$DISK bs=1M && \
reboot
