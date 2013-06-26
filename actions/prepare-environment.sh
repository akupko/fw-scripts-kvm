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


#Check create bridge or not
#idx=200
for (( i=0; i<3; i++ ))
do
	ip=`ip a show dev virbr$idx  `
	if [ $? == 0 ]
		then	
			echo "Bridge exists"
			define_existing_bridge virbr$idx
		else 
			define_network testnet$idx virbr$idx ${bridge_ip[$i]} $netmask
		fi
idx=$((idx+1))
done
