#!/bin/bash

source /home/ubuntu/keystonerc
source /home/ubuntu/queens-clients/bin/activate

openstack bgp dragent add speaker 4258f572-adfe-42dc-bcd5-7bb1a380503e speaker
openstack bgp dragent add speaker 6b08e6f3-728c-4cd6-a2f8-0247b55ba49b speaker
openstack bgp dragent add speaker 7b7b2db1-5c0d-4aa3-8260-e398109ba727 speaker
