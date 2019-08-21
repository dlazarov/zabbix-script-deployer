#!/bin/bash
# Get date from now
# Get date from when the service is in active state
# Transform these date in seconds and substract to get the uptime
container=`echo $1|awk -F '.' '{print $2}'`
service=$2
active_date=$(lxc exec $container -- systemctl show $service -p ActiveEnterTimestamp --value)
now_date=$(lxc exec $container -- date -d now +%s)
expr $now_date - $(date -d "$active_date" +%s)