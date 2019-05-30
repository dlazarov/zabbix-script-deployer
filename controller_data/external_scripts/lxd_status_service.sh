#!/bin/bash

container=`echo $1|awk -F '.' '{print $2}'`
service=$2
/usr/bin/lxc exec $container -- systemctl is-active $service