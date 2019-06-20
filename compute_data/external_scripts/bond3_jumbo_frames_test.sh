#!/bin/bash

hostname=$(hostname)
bond3_status=$(cat /sys/class/net/bond3/operstate)

# check if bond3-used for ceph replication is up on the node and if not exit
if [[ $bond3_status != "up" ]]; then
	echo 100
	exit 1
fi

# depending on which rack is the node ping the controller from the opposite rack
# ex: if the node is in rack 1 then ping the controller from rack 2
if [[ $hostname == *"ocpu-1-"* ]]; then
	# ping octrl2-2 or octrl2-3
	ping -I bond3 -c 4 -M do -s 8972 10.224.42.101 > /dev/null 2>&1
	echo $?
elif [[ $hostname == *"ocpu-2-"* ]]; then
	# ping octrl1-1
	ping -I bond3 -c 4 -M do -s 8972 10.224.42.41 > /dev/null 2>&1
        echo $?
else
	# Hostname is not recognized
	echo 200
fi