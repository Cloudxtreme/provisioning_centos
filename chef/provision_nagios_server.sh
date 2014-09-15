#!/bin/bash

NAME="nagios-server"

function createJsonSshKeyFile() {
    local FILENAME=$1
    local ID=$2
    local PUBLIC_KEY=$3
    echo "Creating Nagios server SSH Key Data Bag"
    echo "{\"id\":\"${ID}\", \"public_key\":\"${PUBLIC_KEY}\"}" > ${FILENAME}
}

rm -rf "${HOME}/tmp/secrets"
mkdir -p "${HOME}/tmp/secrets"

knife rackspace server create -r 'role[monitoring],role[bootstrap]' --flavor 3 --server-name ${NAME} --image 23b564c9-c3e6-49f9-bc68-86c7a9ab5018
ssh_output_string=$(knife ssh name:${NAME} -a ipaddress -x root -P password "su -c 'cat ~/.ssh/id_rsa.pub' -s /bin/sh nagios")

ssh_output=( $ssh_output_string )
NAGIOS_SERVER_PUBLIC_KEY=${ssh_output[1]}
NAGIOS_SERVER_PUBLIC_KEY+=" ${ssh_output[2]}"
NAGIOS_SERVER_PUBLIC_KEY+=" ${ssh_output[3]}"
createJsonSshKeyFile "$HOME/tmp/secrets/${NAME}-public-key.json" ${NAME} "${NAGIOS_SERVER_PUBLIC_KEY}"
echo $(tr -d '\b\r' <"$HOME/tmp/secrets/${NAME}-public-key.json" ) > "$HOME/tmp/secrets/${NAME}-public-key.json"

knife data bag from file --secret-file ${RACKSPACE_ENCRYPTED_BAG_SECRET_LOCATION} public_keys "$HOME/tmp/secrets/${NAME}-public-key.json"

rm -rf "${HOME}/tmp/secrets"

knife ssh name:${NAME} -a ipaddress -x root -P password "chef-client -o role[security] --once"
