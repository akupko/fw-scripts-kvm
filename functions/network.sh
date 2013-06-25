#!/bin/bash

define_network() {
  NAME=$1
  BRIDGE=$2
  IP=$3
  MASK=$4
  TMP_FILE="/tmp/tmp_fw_net.xml"
echo "Creating network template"
  cat <<EOF > ${TMP_FILE}
<network>
  <name>${NAME}</name>
  <bridge name="${BRIDGE}" stp='on' delay='0' />
  <ip address="${IP}" netmask="${MASK}">
  </ip>
</network>
EOF
  virsh net-define ${TMP_FILE}
  virsh net-start ${NAME}
  virsh net-autostart ${NAME}
}


undefine_network() {
  NAME=$1
  virsh net-destroy ${NAME}
  virsh net-undefine ${NAME}
}

# example of network actions
#define_network testnet virbr100 10.99.1.1 255.255.255.0
#undefine_network testnet
