#!/bin/bash
IID=8080
GUESTIP=192.168.0.50
NETDEVIP=192.168.0.49
HASVLAN=0
VLANID=-1
TIMEOUT=-1
RUNNMAP=0
USER=john

TAPDEV=tap${IID}
HOSTNETDEV=${TAPDEV}
MIPSKERNEL="/home/john/Desktop/PSF/Home/alpha-3/bin/vmlinux.mipseb"

sudo tunctl -t ${TAPDEV} -u ${USER}

sudo ifconfig ${TAPDEV} ${NETDEVIP}/24 up

sudo qemu-system-mips -m 256 -M malta -kernel ${MIPSKERNEL} \
	-hda image.hda -append "root=/dev/sda1 console=ttyS0" \
	-serial stdio \
	-serial unix:/tmp/qemu.${IID}.S1,server,nowait \
	-monitor unix:/tmp/qemu.${IID},server,nowait \
	-display none \
	-net nic,vlan=0 -net tap,vlan=0,ifname=${TAPDEV},script=no -net nic,vlan=1 -net user,vlan=1 -net nic,vlan=2 -net user,vlan=2 -net nic,vlan=3 -net user,vlan=3 

echo -e "$(date)\nPress Enter to stop the running emulation ..."
read

echo -e "q\n" | nc -q1 -U /tmp/qemu.${IID}

sudo ifconfig ${TAPDEV} down

sudo tunctl -d ${TAPDEV}
