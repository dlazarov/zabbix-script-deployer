#!/bin/bash
path=/etc/zabbix/external_scripts/process_restart_tmp
filename=`echo $1 | sed 's/\//_/g' | sed 's/$/.tmp/'`
if [ ! -f $path/$filename ]; then
   ps aux | grep $1 | grep -v -e "grep" -e $0 | awk '{print $2}' > $path/$filename
fi
ps aux | grep $1 | grep -v -e "grep" -e $0 | awk '{print $2}' > $path/temp_$filename
# Compare files content
res=`comm -12 --nocheck-order <(sort $path/$filename) <(sort $path/temp_$filename) | wc -l`
# Check if res is 0 and enter retry loop to avoid false positive caused by ps
if [ $res -eq 0 ]; then
        i=0
        while [ $i -le 2 ]; do
                ps aux | grep $1 | grep -v -e "grep" -e $0 | awk '{print $2}' > $path/temp_$filename
                $res=`comm -12 --nocheck-order <(sort $path/$filename) <(sort $path/temp_$filename) | wc -l`
                if [ $res -ne 0 ]; then
                        break
                fi
                let i=i+1
        done
fi
# Rename temporary file created
mv $path/temp_$filename $path/$filename
echo $res
