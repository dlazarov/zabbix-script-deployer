#!/bin/bash

# Config function for controllers
file_config () {

	host_type=$1
	modify_config=$2

	echo "INFO: Copying external scripts to zabbix folder"
	sudo cp -r /home/ubuntu/repo_clone/$host_type/external_scripts/ /etc/zabbix/
	echo "INFO: Changing permissions"
	sudo chown -R zabbix:root /etc/zabbix/external_scripts/
	for file in `ls /etc/zabbix/external_scripts/`; do
		if [[ $file == *.sh ]]; then
			sudo chmod 0770 /etc/zabbix/external_scripts/$file
		fi
	done
	
	echo "INFO: Copying user parameters"
	sudo cp /home/ubuntu/repo_clone/$host_type/custom_user_parameters.conf /etc/zabbix/zabbix_agentd.d/
	
	if [ "$modify_config" == "true" ]; then
		echo "INFO: Copying config file"
		sudo cp /home/ubuntu/repo_clone/$host_type/zabbix_agentd.conf /etc/zabbix/
	fi
}

hostname=`hostname`
modify_config=$1

echo "DEBUG: Hostname is $hostname"

case $hostname in
	*ctrl*)
		echo "DEBUG: Executing controller case for $hostname"
		# Run script that copies all files from controller_data folder
		file_config "controller_data" $modify_config
	;;
	*compute*|*ocpu*)
		echo "DEBUG: Executing compute case for $hostname"
		# Run script that copies all files from compute_data folder
		file_config "compute_data" $modify_config
	;;
	*)
		echo "INFO: No zabbix scripts to be applied for host $hostname"
	;;
esac
# Restart zabbix-agent.service
echo "INFO: Restarting zabbix agent on $hostname"
sudo systemctl restart zabbix-agent


# Cleanup
rm -rf /home/ubuntu/repo_clone