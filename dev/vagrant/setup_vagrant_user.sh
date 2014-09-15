function createJsonPasswordFile() {
    local FILENAME=$1
    local ID=$2
    local USERNAME=$3
    local PASSWORD=$4

    echo "Creating json file ${FILENAME}"
    echo "{ \"id\" : \"${ID}\", \"username\" : \"${USERNAME}\", \"password\" : \"${PASSWORD}\" }" > ${FILENAME}
}
SSH_USER="root"
NODE_NAME="mmurillo-vagrant-centos"
SSH_PASSWORD="secretpassword"
SSH_PASSWORD_SHA=`openssl passwd -1 "${SSH_PASSWORD}"`
createJsonPasswordFile "$HOME/tmp/secrets/${NODE_NAME}.json" ${NODE_NAME} ${SSH_USER} ${SSH_PASSWORD_SHA}
knife data bag from file --secret-file ~/.chef/ureport/ur_data_bag_key node_users "$HOME/tmp/secrets/${NODE_NAME}.json"
