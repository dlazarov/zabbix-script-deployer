#!/bin/bash

container=$1

interfaces=$(lxc exec $container -- cat /etc/netplan/99-juju.yaml | awk '
{
        if ($0 ~ /eth[0-9]/)
                interface_name=substr($1,1,4)

        if ($0 ~ /- 10.224.24|- 10.224.25|- 10.224.49/)
                valid = 1
        else
                valid = 0

        if (valid)
                interfaces=interfaces interface_name " "
}

END {
        print interfaces
}')

output=""

for eth in $interfaces; do
        dns_addr=$(lxc exec $container -- systemd-resolve --status | grep -F "${eth})" -A8 | awk '
        BEGIN {
                dns_ip[0] = "10.224.10.4"
                dns_ip[1] = "10.224.10.56"
                dns_ip[2] = "10.224.10.186"
        }
        {
                for (ip in dns_ip) {
                        if ($0 ~ dns_ip[ip]) {
                                dns_ip[ip] = "ok"
                        }
                }
        }
        END {
                for (ip in dns_ip) {
                        if (dns_ip[ip] != "ok")
                                missing_ip=missing_ip " " dns_ip[ip]
                }
                if (missing_ip)
                        print missing_ip

        }')

        if [[ $dns_addr ]]; then
                output="${output} ${eth}:${dns_addr}"
        else
                echo "ok"
        fi

done
echo $output
