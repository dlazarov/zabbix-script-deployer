# zabbix-script-deployer

## Functionality
Made to run on juju deployed openstack, it helps to deploy scripts that extend zabbix agent functionality, by copying files stored in a github repository to all the controller and compute nodes.

Main script is *script-staging.sh* which clones this repository locally and then it copies it to each machine where it executes *deployer.sh* which itself copies the scripts and the user parameters to the zabbix agent folder.

If *script-staging.sh* is executed without arguments, it will apply the scripts to all the compute and controller nodes available.
If it the script is executed using the arguments *--compute* or *--controller* you will be able pass a number of nodes of each type on which the scripts will be applied or overwritten in case they already existed.
