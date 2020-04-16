#!/bin/bash

# Returns a semicolon separated string of the queues that have more messages
# than the number passed as argument

queue_threshold=$1
container_id=`grep "rabbitmq-server" /etc/zabbix/external_scripts/lxd_index | awk -F "," '{print $2}'`

lxc exec $container_id -- sh -c "rabbitmqctl list_queues -p openstack | tail -n +2" > /tmp/rabbitmq_queues

awk -v threshold="$queue_threshold" '
{
        if ($2 > threshold)
                pools = pools $1 "; "
}
END {
        if (!(pools))
                print "ok"
        else
                print pools
}' < /tmp/rabbitmq_queues