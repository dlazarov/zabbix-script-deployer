#!/bin/bash

# Clone repo
git clone git@github.com:dlazarov/zabbix-script-deployer.git ~/juju/monitoring/repo_clone

# Push repo to all machines and deploy scripts
for machine_id in `juju machines | grep bionic | awk '{print $1}' | grep -v lxd`; do
        echo "Applying scripts on machine $machine_id"
        juju scp -- -r ~/juju/monitoring/repo_clone $machine_id:/home/ubuntu

        juju run --machine $machine_id "chmod +x /home/ubuntu/repo_clone/deployer.sh"
        juju run --machine $machine_id "/home/ubuntu/repo_clone/deployer.sh"
done

# Cleanup
rm -rf ~/juju/monitoring/repo_clone
