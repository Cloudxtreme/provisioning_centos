#!/bin/bash 

set -e

#Command to see the list of supported instance sizes on Rackspace
# knife rackspace flavor list

#ID  Name                     VCPUs  RAM    Disk   
#2   512MB Standard Instance  1      512    20 GB  
#3   1GB Standard Instance    1      1024   40 GB  
#4   2GB Standard Instance    2      2048   80 GB  
#5   4GB Standard Instance    2      4096   160 GB 
#6   8GB Standard Instance    4      8192   320 GB 
#7   15GB Standard Instance   6      15360  620 GB 
#8   30GB Standard Instance   8      30720  1200 GB

#Use "knife rackspace image list" to see the list of available images for Rackspace.

NAME_PREFIX=$1
ENVIRONMENT=$2

APPSERVER_SSH_USER=$3
APPSERVER_SSH_PASSWORD=$4

DBSERVER_SSH_USER=$5
DBSERVER_SSH_PASSWORD=$6

DBSERVER_NODE_NAME="${NAME_PREFIX}${ENVIRONMENT}-dbserver"
APPSERVER_NODE_NAME="${NAME_PREFIX}${ENVIRONMENT}-appserver"

BLOCK_PASSWORD_ACCESS=$7

FLAVOUR=$8

SETUP_DB_SERVER_FLAG=$9
SETUP_PERSISTENT_BACKUP_FLAG=${10}
BACKUP_DBSERVER_USER=${11}
BACKUP_DBSERVER_PASSWORD=${12}

if [ "$SETUP_DB_SERVER_FLAG" == "y" ]
then
    BACKUP_DBSERVER_NODE_NAME="${NAME_PREFIX}${ENVIRONMENT}-backup-dbserver"
fi

function createJsonPasswordFile() {
    local FILENAME=$1
    local ID=$2
    local USERNAME=$3
    local PASSWORD=$4

    echo "Creating json file ${FILENAME}"
    echo "{ \"id\" : \"${ID}\", \"username\" : \"${USERNAME}\", \"password\" : \"${PASSWORD}\" }" > ${FILENAME}
}

function createJsonNetworkingFile() {
    local FILENAME=$1
    local ID=$2
    local APPSERVER_NODE=$3
    local DBSERVER_NODE=$4
    local BACKUP_DBSERVER_NODE=$5

    echo "Creating json file ${FILENAME}"

if [[ -z "${BACKUP_DBSERVER_NODE}" ]];
    then
        echo "{ \"id\" : \"${ID}\", \"appserver_node\" : \"${APPSERVER_NODE}\", \"dbserver_node\" : \"${DBSERVER_NODE}\" }" > ${FILENAME}
    else
        echo "{ \"id\" : \"${ID}\", \"appserver_node\" : \"${APPSERVER_NODE}\", \"dbserver_node\" : \"${DBSERVER_NODE}\",\"backup_dbserver_node\": \"${BACKUP_DBSERVER_NODE}\" }" > ${FILENAME}
fi
   
} 
echo "Putting the passwords into an encrypted databag..."

rm -rf "${HOME}/tmp/secrets"
mkdir -p "${HOME}/tmp/secrets"

DBSERVER_SSH_PASSWORD_SHA=`openssl passwd -1 "${DBSERVER_SSH_PASSWORD}"`
APPSERVER_SSH_PASSWORD_SHA=`openssl passwd -1 "${APPSERVER_SSH_PASSWORD}"`

createJsonPasswordFile "$HOME/tmp/secrets/${DBSERVER_NODE_NAME}.json" ${DBSERVER_NODE_NAME} ${DBSERVER_SSH_USER} ${DBSERVER_SSH_PASSWORD_SHA}
createJsonPasswordFile "$HOME/tmp/secrets/${APPSERVER_NODE_NAME}.json" ${APPSERVER_NODE_NAME} ${APPSERVER_SSH_USER} ${APPSERVER_SSH_PASSWORD_SHA}

knife data bag from file --secret-file ${RACKSPACE_ENCRYPTED_BAG_SECRET_LOCATION} node_users "$HOME/tmp/secrets/${DBSERVER_NODE_NAME}.json"
knife data bag from file --secret-file ${RACKSPACE_ENCRYPTED_BAG_SECRET_LOCATION} node_users "$HOME/tmp/secrets/${APPSERVER_NODE_NAME}.json"

createJsonNetworkingFile "$HOME/tmp/secrets/${DBSERVER_NODE_NAME}-network.json" ${DBSERVER_NODE_NAME} ${APPSERVER_NODE_NAME} ${DBSERVER_NODE_NAME} ${BACKUP_DBSERVER_NODE_NAME}
createJsonNetworkingFile "$HOME/tmp/secrets/${APPSERVER_NODE_NAME}-network.json" ${APPSERVER_NODE_NAME} ${APPSERVER_NODE_NAME} ${DBSERVER_NODE_NAME}

knife data bag from file --secret-file ${RACKSPACE_ENCRYPTED_BAG_SECRET_LOCATION} node_networking "$HOME/tmp/secrets/${DBSERVER_NODE_NAME}-network.json"
knife data bag from file --secret-file ${RACKSPACE_ENCRYPTED_BAG_SECRET_LOCATION} node_networking "$HOME/tmp/secrets/${APPSERVER_NODE_NAME}-network.json"


echo -e "\nProvisioning db_server ...\n"
knife rackspace server create -r 'role[bootstrap],role[db_server]' --environment ${ENVIRONMENT}  --flavor ${FLAVOUR} --image 23b564c9-c3e6-49f9-bc68-86c7a9ab5018 --server-name ${DBSERVER_NODE_NAME} --node-name ${DBSERVER_NODE_NAME} --bootstrap-version 11.4.4

echo -e "\nProvisioning app_server ...\n"
knife rackspace server create -r 'role[bootstrap],role[app_server],role[web_server],role[geoserver]' --environment ${ENVIRONMENT} --flavor ${FLAVOUR} --image 23b564c9-c3e6-49f9-bc68-86c7a9ab5018 --server-name ${APPSERVER_NODE_NAME} --node-name ${APPSERVER_NODE_NAME} --bootstrap-version 11.4.4


if [ "$SETUP_DB_SERVER_FLAG" == "y" ]
then
    BACKUP_DBSERVER_PASSWORD_SHA=`openssl passwd -1 "${BACKUP_DBSERVER_PASSWORD}"`
   
    createJsonPasswordFile "$HOME/tmp/secrets/${BACKUP_DBSERVER_NODE_NAME}.json" ${BACKUP_DBSERVER_NODE_NAME} ${BACKUP_DBSERVER_USER} ${BACKUP_DBSERVER_PASSWORD_SHA}
    knife data bag from file --secret-file ${RACKSPACE_ENCRYPTED_BAG_SECRET_LOCATION} node_users "$HOME/tmp/secrets/${BACKUP_DBSERVER_NODE_NAME}.json"
    createJsonNetworkingFile "$HOME/tmp/secrets/${BACKUP_DBSERVER_NODE_NAME}-network.json" ${BACKUP_DBSERVER_NODE_NAME} ${APPSERVER_NODE_NAME} ${DBSERVER_NODE_NAME}
    knife data bag from file --secret-file ${RACKSPACE_ENCRYPTED_BAG_SECRET_LOCATION} node_networking "$HOME/tmp/secrets/${BACKUP_DBSERVER_NODE_NAME}-network.json"

    echo -e "\nProvisioning backup db server ...\n"
    
    if [ "$SETUP_PERSISTENT_BACKUP_FLAG" == "y" ]
    then
        knife rackspace server create -r 'role[bootstrap],role[persistent_backup_db_server]' --environment ${ENVIRONMENT} --flavor ${FLAVOUR} --image 23b564c9-c3e6-49f9-bc68-86c7a9ab5018 --server-name ${BACKUP_DBSERVER_NODE_NAME} --node-name ${BACKUP_DBSERVER_NODE_NAME} --bootstrap-version 11.4.4
    else
        knife rackspace server create -r 'role[bootstrap],role[backup_db_server]' --environment ${ENVIRONMENT} --flavor ${FLAVOUR} --image 23b564c9-c3e6-49f9-bc68-86c7a9ab5018 --server-name ${BACKUP_DBSERVER_NODE_NAME} --node-name ${BACKUP_DBSERVER_NODE_NAME} --bootstrap-version 11.4.4
    fi
fi
rm -rf "${HOME}/tmp/secrets"

echo -e "\nServers are provisioned.\n"

echo -e "\n Configuring DNS"
./configure_network.sh ${APPSERVER_NODE_NAME} ${APPSERVER_SSH_USER} ${APPSERVER_SSH_PASSWORD}
./configure_network.sh ${DBSERVER_NODE_NAME} ${DBSERVER_SSH_USER} ${DBSERVER_SSH_PASSWORD}

if [ "$SETUP_DB_SERVER_FLAG" == "y" ]
then
    ./configure_network.sh ${BACKUP_DBSERVER_NODE_NAME} ${BACKUP_DBSERVER_USER} ${BACKUP_DBSERVER_PASSWORD}
fi

echo -e "\nDNS configured.\n"


./initialize_database_and_customise_country.sh ${APPSERVER_NODE_NAME} ${APPSERVER_SSH_USER} ${APPSERVER_SSH_PASSWORD}
echo -e "\nDatabase initialised.\n"

if [ "$SETUP_DB_SERVER_FLAG" == "y" ]
then
    echo -e "\nInitialising postgres backup\n"
    ./setup_backup_on_master_dbserver.sh ${DBSERVER_NODE_NAME} ${DBSERVER_SSH_USER} ${DBSERVER_SSH_PASSWORD} ${BACKUP_DBSERVER_NODE_NAME} ${BACKUP_DBSERVER_USER} ${BACKUP_DBSERVER_PASSWORD}
    echo -e "\nCreate fake table on db server to test rsync with backup-dbserver.\n"
    knife ssh name:${DBSERVER_NODE_NAME} -a ipaddress -x ${DBSERVER_SSH_USER} -P ${DBSERVER_SSH_PASSWORD} "psql -U postgres -h localhost -d ureport -c \"create table fake_table (fake integer)\""
    echo -e "\nChecking that fake table got sync on backup-dbserver properly.\n"
    knife ssh name:${BACKUP_DBSERVER_NODE_NAME} -a ipaddress -x ${BACKUP_DBSERVER_USER} -P ${BACKUP_DBSERVER_PASSWORD} "psql -U postgres -h localhost -d ureport -c \"select * from fake_table\""
    knife ssh name:${DBSERVER_NODE_NAME} -a ipaddress -x ${DBSERVER_SSH_USER} -P ${DBSERVER_SSH_PASSWORD} "psql -U postgres -h localhost -d ureport -c \"drop table fake_table\""
fi

if [ "$BLOCK_PASSWORD_ACCESS" == "y" ]
then
    # Block Password Access
    knife ssh name:${APPSERVER_NODE_NAME} -a ipaddress -x ${APPSERVER_SSH_USER} -P ${APPSERVER_SSH_PASSWORD} "chef-client -o 'role[security]' --once"
    knife ssh name:${DBSERVER_NODE_NAME} -a ipaddress -x ${DBSERVER_SSH_USER} -P ${DBSERVER_SSH_PASSWORD} "chef-client -o 'role[security]' --once"
    if [ "$SETUP_DB_SERVER_FLAG" == "y" ]
    then
        knife ssh name:${BACKUP_DBSERVER_NODE_NAME} -a ipaddress -x ${BACKUP_DBSERVER_USER} -P ${BACKUP_DBSERVER_PASSWORD} "chef-client -o 'role[security]' --once"
    fi
fi

#test the provisioning
APPSERVER_IP=$(knife search node $APPSERVER_NODE_NAME -a ipaddress | awk '/ipaddress/ {print $2;}') 
./check_deployed_app.sh $APPSERVER_IP
