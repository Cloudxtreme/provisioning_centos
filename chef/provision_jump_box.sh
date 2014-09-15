#!/bin/bash

NAME="jump-box"

read -s -p "Jump Box Password: " SSH_PASSWORD
echo -e " "

function createJsonPasswordFile() {
    local FILENAME=$1
    local ID=$2
    local USERNAME=$3
    local PASSWORD=$4
    local PROVISIONER_PUBLIC_KEY=$(cat ~/.ssh/id_rsa.pub)
    echo "Creating json file ${FILENAME}"
    echo "{ \"id\" : \"${ID}\", \"username\" : \"${USERNAME}\", \"password\" : \"${PASSWORD}\",\"provisioner_public_key\":\"${PROVISIONER_PUBLIC_KEY}\" }" > ${FILENAME}
}

function createJsonJumpBoxSshKeyFile() {
    local FILENAME=$1
    local ID=$2
    local PUBLIC_KEY=$3
    echo "Creating Jump Box SSH Key Data Bag"
    echo "{\"id\":\"${ID}\", \"public_key\":\"${PUBLIC_KEY}\"}" > ${FILENAME}
}

rm -rf "${HOME}/tmp/secrets"
mkdir -p "${HOME}/tmp/secrets"

SSH_PASSWORD_SHA=`openssl passwd -1 "${SSH_PASSWORD}"`
createJsonPasswordFile "$HOME/tmp/secrets/${NAME}.json" ${NAME} root ${SSH_PASSWORD_SHA}
knife data bag from file --secret-file ${RACKSPACE_ENCRYPTED_BAG_SECRET_LOCATION} node_users "$HOME/tmp/secrets/${NAME}.json"

knife rackspace server create -r 'recipe[setup_jump_box]' --flavor 2 --server-name ${NAME} --image 23b564c9-c3e6-49f9-bc68-86c7a9ab5018
ssh_output_string=$(knife ssh name:${NAME} -a ipaddress -x root  "cat ~/.ssh/id_rsa.pub")

ssh_output=( $ssh_output_string )
JUMP_BOX_PUBLIC_KEY=${ssh_output[1]}
JUMP_BOX_PUBLIC_KEY+=" ${ssh_output[2]}"
JUMP_BOX_PUBLIC_KEY+=" ${ssh_output[3]}"
createJsonJumpBoxSshKeyFile "$HOME/tmp/secrets/${NAME}-public-key.json" ${NAME} "${JUMP_BOX_PUBLIC_KEY}"
echo $(tr -d '\b\r' <"$HOME/tmp/secrets/${NAME}-public-key.json" ) > "$HOME/tmp/secrets/${NAME}-public-key.json"

knife data bag from file --secret-file ${RACKSPACE_ENCRYPTED_BAG_SECRET_LOCATION} public_keys "$HOME/tmp/secrets/${NAME}-public-key.json"

rm -rf "${HOME}/tmp/secrets"
