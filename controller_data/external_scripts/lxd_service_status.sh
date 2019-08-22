#!/bin/bash

container_id=$1
service=$2

active_state=$(lxc exec $container_id -- systemctl show -p ActiveState $service | awk -F "=" '{print $2}')
sub_state=$(lxc exec $container_id -- systemctl show -p SubState $service | awk -F "=" '{print $2}')

printf "%s %s" "$active_state" "$sub_state"