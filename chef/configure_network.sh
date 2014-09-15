#!/bin/bash

# Add -VV to the end to see debugging verbose
# If you are doing this multiple times with the same node names, make sure you delete both the chef client AND the node from the chef server before trying again


NODE_NAME=$1
NODE_SSH_USER=$2
NODE_SSH_PASSWORD=$3

echo -e "Configuring DNS on node [${NODE_NAME}] ..."

knife ssh name:${NODE_NAME} -a ipaddress -x ${NODE_SSH_USER} -P ${NODE_SSH_PASSWORD} "sudo chef-client -o 'role[networking]' --once"

