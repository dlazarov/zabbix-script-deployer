#!/bin/bash

# Config function for controllers
file_config () {
	echo "INFO: Copying external scripts to zabbix folder"
	sudo cp -r /home/ubuntu/repo_clone/$1/external_scripts/ /etc/zabbix/
	echo "INFO: Changing permissions"
	sudo chown -R zabbix:root /etc/zabbix/external_scripts/
	for file in `ls /etc/zabbix/external_scripts/`; do
		if [[ $file == *.sh ]]; then
			sudo chmod 0770 /etc/zabbix/external_scripts/$file
		fi
	done
	echo "INFO: Copying user parameters"
	sudo cp /home/ubuntu/repo_clone/$1/custom_user_parameters.conf /etc/zabbix/zabbix_agentd.d/
}

hostname=`hostname`

echo "DEBUG: Hostname is $hostname"

case $hostname in
	*ctrl*)
		echo "DEBUG: Executing controller case for $hostname"
		# Run script that copies all files from controller_data folder
		file_config "controller_data"
	;;
	*compute*|*ocpu*)
		echo "DEBUG: Executing compute case for $hostname"
		# Run script that copies all files from compute_data folder
		file_config "compute_data"
	;;
	*)
		echo "INFO: No zabbix scripts to be applied for host $hostname"
	;;
esac
# Restart zabbix-agent.service
sudo systemctl restart zabbix-agent


# Cleanup
rm -rf /home/ubuntu/repo_clone