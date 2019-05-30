#!/bin/bash
hostname=`hostname`
containers=`lxc list -c ns | awk '/RUNNING/ { print $2}'`

echo "{"
echo "     \"data\":["

comma=""
for container in $containers; do
    echo "     $comma{"
    echo "           \"{#CONTAINER}\":\"$container\","
    echo "           \"{#LXDNODE}\":\"$hostname\""
    echo "     }"
    comma=","
done

echo "     ]"
echo "}"