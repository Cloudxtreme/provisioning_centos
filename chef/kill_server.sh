#!/bin/bash

SERVER_ID=$1

if [[ -z "${SERVER_ID}" ]]; then
    echo -e "\nServer ID not provided. Choose one of the following servers:"
    echo -e "Fetching server list. Please wait..."
    knife rackspace server list
    echo -e "\n"
    read -p "Server ID: " SERVER_ID
fi

cmd="knife rackspace server list | awk '/$SERVER_ID/ {print \$2;}'"
NAME=$(eval $cmd)

echo Server name is $NAME 
echo Are you sure you want to delete the server $NAME? -- THIS CANNOT BE UNDONE! 

read -p "Please type the name of the server: " DELETE_CONFIRMATION

if [ "$DELETE_CONFIRMATION" == "$NAME" ]
then
    echo Killing any backup agent associated
    ruby remove_backup_agent.rb $RACKSPACE_USERNAME $RACKSPACE_API_KEY "$NAME"    
    echo Killing server $SERVER_ID
    knife rackspace server delete $SERVER_ID --purge
    
    if [[ -z "${NAME}" ]]; then
        echo "WARNING: Couldn't find the server name from Rackspace -- will not touch the node_networking data bag." 
    else
        knife data bag delete node_networking $NAME -y
        knife data bag delete node_users $NAME -y
    fi
else
    echo Not deleting anything, cya!
fi
