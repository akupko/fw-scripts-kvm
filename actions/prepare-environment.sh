#!/bin/bash

# Include the script with handy functions to operate VMs and Virtual networking
source config.sh 
source functions/vm.sh
source functions/network.sh

netmask=255.255.255.0

# Check for ISO image to be available
#echo -n "Checking for Fuel Web ISO image... "
#if [ -z $iso_path ]; then
#    echo "Fuel Web image is not found. Please download it and put under 'iso' directory."
#    exit 1
#fi
#echo "OK"

#Check net
#List all network
net_list=`virsh net-list | awk '{print $1}' | sed '1,2d'`
echo "This network located on you PC $net_list"

#List bridge
for i in $net_list
do
        br_list=`virsh net-info $i | grep Bridge | awk '{print $2}'`
        brs_list+="$br_list "
done
unset $i
echo "This bridge located on you PC $brs_list"


#Check create bridge or not
idx=100
for (( i=0; i<3; i++ ))
do

	ip=`ip a show dev virbr$idx  `
	if [ $? == 0 ]
		then	
			echo "Bridge exists"
		else 
			define_network testnet$idx virbr$idx ${bridge_ip[$i]} $netmask
		fi
	idx=$(($idx+1))
done
