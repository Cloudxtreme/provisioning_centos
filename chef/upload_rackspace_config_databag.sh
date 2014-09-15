function createJsonRackspaceConfigFile() {
    local FILENAME=$1
    local ID="main"

    echo "Creating json file ${FILENAME}"
    echo "{ \"id\" : \"${ID}\", \"username\" : \"${RACKSPACE_USERNAME}\", \"password\" : \"${RACKSPACE_API_KEY}\" }" > ${FILENAME}
}
rm -rf "${HOME}/tmp/secrets"
mkdir -p "${HOME}/tmp/secrets"

createJsonRackspaceConfigFile "${HOME}/tmp/secrets/rackspace_config_data_bag.json"

knife data bag from file --secret-file ${RACKSPACE_ENCRYPTED_BAG_SECRET_LOCATION} rackspace_config  "${HOME}/tmp/secrets/rackspace_config_data_bag.json"

rm -rf "${HOME}/tmp/secrets"


