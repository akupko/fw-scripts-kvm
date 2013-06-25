#!/bin/bash 

# This file contains the functions to manage VMs in through VirtualBox CLI

get_vm_base_path() {
    virsh pool-dumpxml default | grep path | sed  's/.*<path>//;s/<\/path>//'
}

get_vms_running() {
    virsh list | grep running | awk '{print $2}'
}

get_vms_present() {
    virsh list | grep -E "running|shut off" | awk '{print $2}'
}

is_vm_running() {
    name=$1
    list=$(get_vms_running)

    # Check that the list of running VMs contains the given VM
    if [[ $list = *$name* ]]; then
        return 0
    else
        return 1
    fi
}

create_vm() {
    name=$1
    nic=$2
    cpu_cores=$3
    memory_mb=$4
    disk_mb=$5
    HYPERVISOR="qemu:///system"
   
    # Create virtual machine with the right name and type (assuming CentOS) 
    virt-install --connect=${HYPERVISOR} --name=${name} --arch=x86_64 --vcpus=${cpu_cores} --ram=${memory_mb} --os-type=linux --os-variant=rhel6 --hvm --accelerate --vnc --noautoconsole --keymap=en-us

    # Configure main network interface
    add_nic_to_vm $name $nic

    # Create and attach the main hard drive
    add_disk_to_vm $name 0 $disk_mb
}

add_nic_to_vm() {
    name=$1
    nic=$2
    echo "Adding NIC to $name and bridging with host NIC $nic..."

    # Configure network interfaces
    attach-interface ${name} --type network --source ${nic} --persistent
}

add_disk_to_vm() {
    vm_name=$1
    port=$2
    disk_mb=$3
    case $port in 
	1)
	  target="sdb"
	;;
	2)
	  target="sdc"
	;;
	*)
	  target="sda"
	;;
    esac

    echo "Adding disk to $vm_name, with size $disk_mb Mb..."

    vm_disk_path="$(get_vm_base_path)/"
    disk_name="${vm_name}_${port}"
    disk_filename="${disk_name}.qcow2"
    qemu-img create -f qcow2 ${vm_disk_path}/${disk_filename} ${disk_mb}M
    attach-disk ${vm_name} --source ${vm_disk_path}/${disk_filename} --target $target
}

delete_vm() {
    name=$1
    vm_base_path=$(get_vm_base_path)
    vm_path="$vm_base_path/$name/"

    # Power off VM, if it's running
    if is_vm_running $name; then
        VBoxManage controlvm $name poweroff
    fi

    # Virtualbox does not fully delete VM file structure, so we need to delete the corresponding directory with files as well 
    if [ -d "$vm_path"  ]; then
        echo "Deleting existing virtual machine $name..."
        VBoxManage unregistervm $name --delete
        rm -rf "$vm_path"
    fi
}

delete_vms_multiple() {
    name_prefix=$1
    list=$(get_vms_present)

    # Loop over the list of VMs and delete them, if its name matches the given refix 
    for name in $list; do
        if [[ $name == $name_prefix* ]]; then
            echo "Found existing VM: $name. Deleting it..."
            delete_vm $name 
        fi
    done
}

start_vm() {
    name=$1

    # Just start it
    #VBoxManage startvm $name --type headless
    VBoxManage startvm $name
}

mount_iso_to_vm() {
    name=$1
    iso_path=$2
 
    # Mount ISO to the VM
    VBoxManage storageattach $name --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium "$iso_path"
}

enable_network_boot_for_vm() {
    name=$1

    # Set the right boot priority
    VBoxManage modifyvm $name --boot1 disk --boot2 net --boot3 none --boot4 none --nicbootprio1 1
}
