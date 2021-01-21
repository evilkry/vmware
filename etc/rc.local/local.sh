#!/bin/sh ++group=host/vim/vmvisor/boot
# EDITED 01/20/2021
# local configuration options

vusb0_status=$(esxcli network nic get -n vusb0 | grep 'Link Status' | awk '{print $NF}')
count=0
while [[ $count -lt 20 && "${vusb0_status}" != "Up" ]]
do
    sleep 10
    count=$(( $count + 1 ))
    vusb0_status=$(esxcli network nic get -n vusb0 | grep 'Link Status' | awk '{print $NF}')
done

if [ "${vusb0_status}" = "Up" ]; then

    esxcfg-vswitch -L vusb0 iSCSI

    esxcfg-vswitch -M vusb0 -p "iscsi" iSCSI

# Note: create portgroups

esxcli network vswitch standard portgroup add --portgroup-name=iscsi --vswitch-name=iSCSI

# Note: create vSwitches

esxcli network vswitch standard uplink add --uplink-name=vusb0 --vswitch-name=iSCSI

sleep 5

esxcli software set --enabled=true
esxcli iscsi networkportal add --nic vmk1 --adapter vmhba64
esxcli iscsi adapter discovery sendtarget add -a 172.16.50.5:3260 -A vmhba64

sleep 20  
esxcli storage core adapter rescan --adapter vmhba64   

fi



#esxcfg-vswitch -R

# Note: modify at your own risk!  If you do/use anything in this
# script that is not part of a stable API (relying on files to be in
# specific places, specific tools, specific output, etc) there is a
# possibility you will end up with a broken system after patching or
# upgrading.  Changes are not supported unless under direction of
# VMware support.

# Note: This script will not be run when UEFI secure boot is enabled.
exit 0
