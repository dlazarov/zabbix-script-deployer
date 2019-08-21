#!/bin/bash

source /home/ubuntu/keystonerc
source /home/ubuntu/queens-clients/bin/activate

openstack bgp speaker show dragents speaker -f value | wc -l