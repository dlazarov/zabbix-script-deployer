#!/bin/bash
container=`echo $1|awk -F '.' '{print $2}'`

services=`lxc exec $container -- systemctl list-units -t service | grep "barbican\|ceilometer\|ceph\|cinder\|etcd\|glance\|gnocchi\|heat\|keystone\|magnum\|memcached\|neutron\|nova\|ovsdb\|apache2\|mysql\|rabbitmq-server\|vault" | grep -v "juju" | grep -o "\w.*.service"`

echo "{"
echo "     \"data\":["

comma=""
for service in $services; do
    echo "     $comma{"
    echo "           \"{#SERVICE}\":\"$service\""
    echo "     }"
    comma=","
done

echo "     ]"
echo "}"