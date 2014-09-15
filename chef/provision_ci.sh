#!/bin/bash

set -e

SERVER_LIST=$(knife rackspace server list)

DBSERVER_GUID=$(echo "$SERVER_LIST" | grep "\bci-dev-dbserver\b" | cut -d ' ' -f 1)
APPSERVER_GUID=$(echo "$SERVER_LIST" | grep "\bci-dev-appserver\b" | cut -d ' ' -f 1)
BACKUP_DBSERVER_GUID=$(echo "$SERVER_LIST" | grep "\bci-dev-backup-dbserver\b" | cut -d ' ' -f 1)

if [[ ! -z "$DBSERVER_GUID" ]];
then
    echo -e "ci-dev-dbserver\ny" | ./kill_server.sh $DBSERVER_GUID
fi

if [[ ! -z "$APPSERVER_GUID" ]]; 
then
    echo -e "ci-dev-appserver\ny" | ./kill_server.sh $APPSERVER_GUID
fi

if [[ ! -z "$BACKUP_DBSERVER_GUID" ]];
then
    echo -e "ci-dev-backup-dbserver\ny" | ./kill_server.sh $BACKUP_DBSERVER_GUID
fi

./provision_new_env.sh n < ci_environment.args

knife ssh name:ci-dev-appserver -a ipaddress -x root -P $APPSERVER_SSH_PASSWORD "chef-client -o 'role[test_server]' --once"
