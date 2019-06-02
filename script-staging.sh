#!/bin/bash

function staging () {

	branch=$1
	machine_id=$2
	config=$3

	git clone -b $branch git@github.com:dlazarov/zabbix-script-deployer.git ~/juju/monitoring/repo_clone
	juju scp -- -r ~/juju/monitoring/repo_clone $machine_id:/home/ubuntu
	juju run --machine $machine_id "chmod +x /home/ubuntu/repo_clone/deployer.sh"
	juju run --machine $machine_id "/home/ubuntu/repo_clone/deployer.sh $config"
}

function stagingScope () {

	branch=$1
	scope=$2
	machine_type=$3
	config=$4
	machine_type_name=$5


	# Check if machine_type variable is empty, if it is, run staging for scope which is a single machine ID
	if [ "$machine_type" = false ]; then
		# Running staging once using $scope as ID
		if [ -z "$scope" ]; then
			echo "You must provide a valid machine id when using the -i|--id option. Use -h option for usage help"
		else
			echo "Applying scripts to machine $scope"
			staging $branch $scope $config
	else
		# Running staging for given machine type
		if [ -z "$scope" ]; then
			# Applying script to both compute and controller nodes
			echo "Scripts will be applied to $machine_type_name nodes"
			for machine_id in `juju status | sed -n '/Unit.*Workload/,/Machine.*State/p' | awk '{printf "%s %s \n",$1,$4}' | tail -n +2 | head -n -2 | grep -E '$machine_type' | awk '{print $2}'`; do
				echo "Applying scripts to machine $scope"
				staging $branch $machine_id $config
			done
		else
			echo "Scripts will be applied to $scope $machine_type_name nodes"
			count=0
			for machine_id in `juju status | sed -n '/Unit.*Workload/,/Machine.*State/p' | awk '{printf "%s %s \n",$1,$4}' | tail -n +2 | head -n -2 | grep -E '$machine_type' | awk '{print $2}'`; do
				echo "Applying scripts to machine $scope"
				staging $branch $machine_id $config
				let count=count+1
				if [ "$count" -eq "$scope" ]; then
		        	echo "Scripts applied to $count $machine_type_name nodes"
		        	exit 2
		        fi
			done
		fi

	fi

}

branch="master"
scope=""
machine_type=false
config=false
machine_type_name=""

while (( "$#" )); do
	case "$1" in
		-a|--all)
			machine_type="nova-compute|neutron-gateway"
			machine_type_name="controller and compute"
			shift
			;;
		--compute)
			machine_type="nova-compute"
			machine_type_name="compute"
			re='^[0-9]+$'
			if [[ $2 =~ $re ]]; then
   				scope=$2
   				shift 2
   			else
   				shift
			fi
			;;
		--controller)
			machine_type="neutron-gateway"
			machine_type_name="controller"
			re='^[0-9]+$'
			if [[ $2 =~ $re ]]; then
   				scope=$2
   				shift 2
   			else
   				shift
			fi
			;;
		-i|--id)
			re='^[0-9]+$'
			if ! [[ $2 =~ $re ]] ; then
			   echo "Invalid ID. Use -h option for usage help"
			   exit 1
			else
				scope=$2
				shift 2
			fi
			;;
		-b|--branch)
			branch=$2
			shift 2
			;;
		-t|--test)
			branch="development"
			shift
			;;
		--config)
			config=true
			shift
			;;
		-h|--help)
			echo "Usage: ./script-staging.sh [OPTION] [VALUE]"
			echo
			echo "  --a | --all           The script will run for all the controller and compute nodes."
			echo "  --compute [VALUE]     Runs the script for the given number of compute nodes. If a value is not provided, it will run for all compute nodes."
			echo "  --controller [VALUE]  Runs the script for the given number of controller nodes. If a value is not provided, it will run for all controller nodes."
			echo "  -b | --branch [VALUE] Applies scripts from the given branch."
			echo "  -t | --test           Applies the scripts from the development branch."
			echo "  --config              Overwrites zabbix agent config file too."
			echo "  -h, --help            Displays help menu and exits."
			echo
			exit 1
		;;
		*)
			echo "ERROR: $1 is an unsupported flag. Exiting"
			exit 1
			;;
	esac
done


if [ -z "$machine_type_name" ]; then
	read -p "Zabbix scripts on machine $scope will be overwritten with the scripts from $branch branch. Are you sure you want to continue? (y/n). Use -h option for usage. " -n 1 -r
else
	read -p "Zabbix scripts on $scope $machine_type_name nodes will be overwritten with the scripts from $branch branch. Are you sure you want to continue? (y/n). Use -h option for usage. " -n 1 -r
fi
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	stagingScope $branch $scope $machine_type $config $machine_type_name
elif [[ $REPLY =~ ^[Nn]$ ]]; then
	exit 1
fi
