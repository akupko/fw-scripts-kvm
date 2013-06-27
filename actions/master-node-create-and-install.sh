#!/bin/bash 

#
# This script creates a master node for the product, launches its installation,
# and waits for its completion
#

# Include the handy functions to operate VMs and track ISO installation progress
source config.sh
source functions/vm.sh
source functions/product.sh

# Create master node for the product
name="${env_name_prefix}master"
delete_vm $name
echo
create_vm $name ${host_net_name[`echo ${!host_net_name[*]} | cut -d " " -f 1`]} $vm_master_cpu_cores $vm_master_memory_mb $vm_master_disk_mb
echo

# Adding brdige NIC if any
if [[ $use_bridge == 1 ]]; then
   add_br_nic_to_vm #name $br_name
fi

# Add other host-only nics to VM

for i in `seq 2 ${#host_net_name[*]}`
do 
  add_nic_to_vm $name ${host_net_name[`echo ${!host_net_name[*]} | cut -d " " -f $i`]}	
done

#

mount_iso_to_vm $name $iso_path

# Start virtual machine with the master node
echo
start_vm $name

# Wait until the machine gets installed and Puppet completes its run
wait_for_product_vm_to_install $vm_master_ip $vm_master_username $vm_master_password "$vm_master_prompt"

# Report success
echo
echo "Master node has been installed."
