#!/bin/bash
service=$1
active_date=$(systemctl show $service -p ActiveEnterTimestamp --value)
now_date=$(date -d now +%s)
expr $now_date - $(date -d "$active_date" +%s)