#!/bin/bash
container=$(echo $1 | awk -F '.' '{print $2}')
unit_name=$(grep $container /etc/zabbix/external_scripts/lxd_index | awk -F ',' '{print $1}')

services=$(lxc exec $container -- systemctl list-units -t service | grep "barbican\|ceilometer\|ceph\|cinder\|etcd\|glance\|gnocchi\|heat\|keystone\|magnum\|memcached\|neutron\|nova\|ovsdb\|apache2\|mysql\|rabbitmq-server\|vault" | grep -v "juju" | grep -o "\w.*.service")

echo "{"
echo "\"data\":["

comma=""
for service in $services; do
    echo "$comma{"
    echo "\"{#SERVICE}\":\"$service\","
    echo "\"{#UNIT_NAME}\":\"$unit_name\","
    echo "\"{#CONTAINER}\":\"$container\""
    echo "}"
    comma=","
done

echo "]"
echo "}"