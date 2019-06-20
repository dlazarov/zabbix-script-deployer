#!/bin/bash

$container_id=`grep "ceph-mon" /etc/zabbix/external_scripts/lxd_index | awk '{print $2}'`

status=`lxc exec $container_id -- sh -c "ceph status" | grep health | awk '{print $2}'`
echo $status