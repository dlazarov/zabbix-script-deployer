#!/bin/bash

container=$1
dns_ip=$2


/usr/bin/lxc exec $container -- systemd-resolve --status | awk -v dns_ip="$dns_ip" '

BEGIN {
        FS=":"
        go = 0
        ind = 0
}

{
        if ($0 ~ /DNS Servers:/) {
                go = 1
                gsub(/ /,"",$2)
                ips[ind]=$2
                ind += 1
                next
        }
        if (go == 1) {
                if ($0 !~ /Link|^$/) {
                        gsub(/ /,"")
                        ips[ind]=$0
                        ind += 1
                }
                else {
                        exit
                }
        }

}

END {
        for (i in ips) {
                if (dns_ip == ips[i]) {
                        print 1
                        exit
                }
        }
        print 0
}'