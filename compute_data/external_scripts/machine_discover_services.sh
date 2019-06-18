#!/bin/bash
services=`systemctl list-units -t service | grep "barbican\|ceilometer\|ceph\|cinder\|filebeat\|etcd\|glance\|gnocchi\|heat\|keystone\|magnum\|memcached\|neutron\|nova\|ovsdb\|apache2\|mysql\|rabbitmq-server\|vault\|libvirtd" | grep -v "juju\|ceph-osd@all" | grep -o "\w.*.service"`

echo "{"
echo "     \"data\":["

comma=""
for service in $services
do
    echo "     $comma{"
    echo "           \"{#SERVICE}\":\"$service\""
    echo "     }"
    comma=","
done

echo "     ]"
echo "}"