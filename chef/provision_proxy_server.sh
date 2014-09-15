#!/bin/bash

NODE_NAME=$1
NODE_USERNAME="root"
NODE_PASSWORD="password"


if [[ -z "$NODE_NAME" ]]
then
	echo "Node name required!"
	exit
fi	

echo -e "\nProvisioning proxy_server ...\n"
knife rackspace server create -r 'role[bootstrap],role[proxy]' --flavor 3 --image 23b564c9-c3e6-49f9-bc68-86c7a9ab5018 --server-name ${NODE_NAME} --node-name ${NODE_NAME} --bootstrap-version 11.4.4

knife ssh name:${NODE_NAME} -a ipaddress -x ${NODE_USERNAME} -P ${NODE_PASSWORD} "chef-client -o 'role[security]' --once"


echo -e "\nProxy server has been provisioned.\n"


