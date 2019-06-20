#!/bin/bash
hostname=`hostname`

echo "{"
echo "     \"data\":["

comma=""
for line in `cat /etc/zabbix/external_scripts/lxd_index`; do
    echo "     $comma{"
    echo "           \"{#UNIT_NAME}\":\"`echo $line | awk -F "," '{print $1}'`\","
    echo "           \"{#CONTAINER}\":\"`echo $line | awk -F "," '{print $2}'`\","
    echo "           \"{#LXD_NODE}\":\"$hostname\""
    echo "     }"
    comma=","
done

echo "     ]"
echo "}"
