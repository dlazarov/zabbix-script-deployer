#!/bin/bash

container_id=`grep "ceph-mon" /etc/zabbix/external_scripts/lxd_index | awk -F "," '{print $2}'`
# Value depends on argument passed from zabbix (total_bytes, total_avail_bytes, total_used_bytes)
value=`lxc exec "$container_id" -- sh -c "ceph df -f json-pretty" | grep "$1" | awk '{print $2}' | sed 's/,//'`
# Returned value is converted to Gigabytes
expr $value / 1024 / 1024 / 1024
