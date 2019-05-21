#!/bin/bash
containerId="juju-0f940e-0-lxd-2"
str=`/usr/bin/sudo -u ubuntu lxc exec $containerId -- sh -c "sudo ceph df -f json-pretty" |grep "total_" | awk '{print $2}' | sed 's/,//'`
{ read total; read used; read available;} <<< "${str}"
printf %.2f\\n "$(( 100 * used / total  ))"
