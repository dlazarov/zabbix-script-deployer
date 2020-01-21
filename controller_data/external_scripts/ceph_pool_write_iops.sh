#!/bin/bash
pool_name=$1

container_id=`grep "ceph-mon" /etc/zabbix/external_scripts/lxd_index | awk -F "," '{print $2}'`
write_iops=$(lxc exec $container_id -- sh -c "ceph osd pool stats $pool_name -f json | jq -r '.[].client_io_rate.write_op_per_sec'")

echo $write_iops