#!/bin/bash

# Config function for controllers
file_config () {
	sudo cp -r /home/ubuntu/repo_clone/$1/external_scripts/ /etc/zabbix/
	sudo chown zabbix:root /etc/zabbix/external_scripts/
	for file in `ls /etc/zabbix/external_scripts/`; do
		if [[ $file == *.sh ]]; then
			sudo chmod 0770 /etc/zabbix/external_scripts/$file
		fi
	done

	sudo cp /home/ubuntu/repo_clone/$1/custom_user_parameters.conf /etc/zabbix/zabbix_agentd.d/
}

hostname=`hostname`

case $hostname in
	[*octrl*])
		# Run script that copies all files from controller_data folder
		file_config "controller_data"
	;;
	[*ocpu*])
		# Run script that copies all files from compute_data folder
	;;
	*)
		echo "INFO: No zabbix scripts to be applied for host $hostname"
	;;
esac
# Restart zabbix-agent.service
sudo systemctl restart zabbix-agent


# Cleanup
rm -rf /home/ubuntu/repo_clone