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

user_in_group () {
	if id -nG "$1" | grep -Fqw "$2"; then
        echo "INFO: User $1 is already a member of the $2 group"
	else
        echo "INFO: Adding user $1 to $2 group"
        sudo usermod -aG $2 $1
	fi
}

zabbix_home_dir () {
	zabbix_dir=`echo ~zabbix`

	if [ -d "$zabbix_dir" ]; then
        echo "INFO: Zabbix home directory exists"
	else
        echo "INFO: Creating zabbix home directory at $zabbix_dir"
        sudo mkdir $zabbix_dir
        echo "INFO: Changing directory ownership for $zabbix_dir"
        sudo chown zabbix:zabbix $zabbix_dir
	fi
}

copy_lxd_index () {
	machine_id=$1

	# Overwrite the data with the lxd indexes corresponding to the current node
	echo "INFO: Updating lxd_index on controller $machine_id"
	sudo grep "$machine_id-lxd-"  /home/ubuntu/repo_clone/controller_data/lxd_index > /home/ubuntu/repo_clone/controller_data/lxd_index_$machine_id
	sudo cp /home/ubuntu/repo_clone/controller_data/lxd_index_$machine_id /etc/zabbix/external_scripts/lxd_index

}

create_zabbix_sudoers () {
	if [ -f /etc/sudoers.d/zabbix_sudoers ]; then
		echo "INFO: Zabbix_sudoers file already exists"
	else
		echo "INFO: Checking zabbix_sudoers with visudo"
		sudo chown root:root /home/ubuntu/repo_clone/compute_data/zabbix_sudoers && \
		sudo chmod 440 /home/ubuntu/repo_clone/compute_data/zabbix_sudoers && \
		sudo visudo -c -q -f /home/ubuntu/repo_clone/compute_data/zabbix_sudoers
		if [ "$?" -eq "0" ]; then
			echo "INFO: Visudo check passed. Copying zabbix_sudoers to /etc/sudoers.d/"
			sudo cp /home/ubuntu/repo_clone/compute_data/zabbix_sudoers /etc/sudoers.d/
		else
			echo "ERROR: Visudo check failed."
		fi
	fi
}

hostname=`hostname`
modify_config=$1
machine_id=$2

echo "DEBUG: Hostname is $hostname"

case $hostname in
	*ctrl*)
		echo "DEBUG: Executing controller case for $hostname"
		# Run script that copies all files from controller_data folder
		user_in_group "zabbix" "lxd"
		zabbix_home_dir
		file_config "controller_data" $modify_config
		copy_lxd_index $machine_id
	;;
	*compute*|*ocpu*)
		echo "DEBUG: Executing compute case for $hostname"
		# Run script that copies all files from compute_data folder
		create_zabbix_sudoers
		file_config "compute_data" $modify_config
	;;
	*)
		echo "INFO: No zabbix scripts available for host $hostname"
	;;
esac
# Restart zabbix-agent.service
echo "INFO: Restarting zabbix agent on $hostname"
sudo systemctl restart zabbix-agent.service


# Cleanup
rm -rf /home/ubuntu/repo_clone