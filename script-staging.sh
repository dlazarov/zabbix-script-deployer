#!/bin/bash

function staging () {
	juju scp -- -r ~/juju/monitoring/repo_clone $1:/home/ubuntu
	juju run --machine $1 "chmod +x /home/ubuntu/repo_clone/deployer.sh"
	juju run --machine $1 "/home/ubuntu/repo_clone/deployer.sh"
}

# Clone repo
git clone git@github.com:dlazarov/zabbix-script-deployer.git ~/juju/monitoring/repo_clone

if [ $# -eq 0 ]; then
	read -p "No arguments were supplied. This will apply the changes to all the controller and compute nodes. Are you sure you want to continue? (y/n). Use -h option for usage. " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		for machine_id in `juju status | sed -n '/Unit.*Workload/,/Machine.*State/p' | awk '{printf "%s %s \n",$1,$4}' | tail -n +2 | head -n -2 | grep -E 'nova-compute|neutron-gateway' | awk '{print $2}'`; do
			echo "Applying zabbix scripts on machine $machine_id"
			staging $machine_id
		done
	elif [[ $REPLY =~ ^[Nn]$ ]]; then
		exit 1
	fi
else
	case $1 in
		--compute)
			if [ -z "$2" ] || [ "$2" -le 0 ]; then
				echo "Invalid number of nodes. The value must be a positive integer. Use -h option for usage."
				exit 1
			else
				computeNodes=`juju status | sed -n '/Unit.*Workload/,/Machine.*State/p' | awk '{printf "%s %s \n",$1,$4}' | tail -n +2 | head -n -2 | grep nova-compute | wc -l`
				if [ "$computeNodes" -lt "$2" ]; then
					echo "You only have $computeNodes compute nodes available."
				else
					echo "Running script for $2 compute nodes."
					copies=0
					for machine_id in `juju status | sed -n '/Unit.*Workload/,/Machine.*State/p' | awk '{printf "%s %s \n",$1,$4}' | tail -n +2 | head -n -2 | grep nova-compute | awk '{print $2}'`; do
						echo "Applying zabbix scripts on machine $machine_id"
        				staging $machine_id
				        let copies=copies+1
				        if [ "$copies" -eq "$2" ]; then
				        	echo "DONE"
				        	exit 2
				        fi
					done
				fi
			fi
		;;
		--controller)
			if [ -z "$2" ] || [ "$2" -le 0 ]; then
				echo "Invalid number of nodes. The value must be a positive integer. Use -h option for usage."
				exit 1
			else
				controllerNodes=`juju status | sed -n '/Unit.*Workload/,/Machine.*State/p' | awk '{printf "%s %s \n",$1,$4}' | tail -n +2 | head -n -2 | grep neutron-gateway | wc -l`
				if [ "$controllerNodes" -lt "$2" ]; then
					echo "You only have $controllerNodes controller nodes available."
				else
					echo "Running script for $2 controller nodes."
					copies=0
					for machine_id in `juju status | sed -n '/Unit.*Workload/,/Machine.*State/p' | awk '{printf "%s %s \n",$1,$4}' | tail -n +2 | head -n -2 | grep neutron-gateway | awk '{print $2}'`; do
						echo "Applying zabbix scripts on machine $machine_id"
        				staging $machine_id
				        let copies=copies+1
				        if [ "$copies" -eq "$2" ]; then
				        	echo "DONE"
				        	exit 2
				        fi
					done
				fi
				# Run command for provided number of compute nodes
			fi
		;;
		-h|--help)
			echo "Usage: ./script-staging.sh [OPTION] [VALUE]"
			echo
			echo "If no option is used, the script will run for all the controller and compute nodes."
			echo "  --compute [VALUE]     Runs the script for the given number of compute nodes."
			echo "  --controller [VALUE]  Runs the script for the given number of controller nodes."
			echo "  -h, --help            Display this help and exit."
			echo
			exit 1
		;;
		*)
			echo "Invalid option. Use -h option for usage."
			exit 1
		;;
	esac
fi

# Cleanup
rm -rf ~/juju/monitoring/repo_clone
