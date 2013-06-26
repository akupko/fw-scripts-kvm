#!/bin/bash

# Include the script with handy functions to operate VMs and Virtual networking
source config.sh 
source functions/vm.sh
source functions/network.sh

#netmask=255.255.255.0

# Check for ISO image to be available
#echo -n "Checking for Fuel Web ISO image... "
#if [ -z $iso_path ]; then
#    echo "Fuel Web image is not found. Please download it and put under 'iso' directory."
#    exit 1
#fi
#echo "OK"


#Check create bridge or not and create if not exist

for idx1 in $idx_list
do
	ip=`ip a show dev ${host_net_bridge[$idx1]}`
	if [ $? == 0 ]; then	
		echo "Bridge exists"
		check_existing_bridge ${host_net_bridge[$idx1]}
		NET_ERR="True"
	fi
done

if [ -n $NET_ERR ]; then
	echo "ERROR: Some of bridges are already used, please check existing networks or redefine [idx] variable in config.sh"
	exit 1
fi

define_network ${host_net_name$[idx]} ${host_net_bridge[$idx1]} ${host_nic_ip[$idx1]} ${host_nic_mask[$idx1]}
