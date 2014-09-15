#!/bin/bash

SERVER_ID=$1
SINGAPORE_REGION="ap-southeast-1"
PROVIDER="AMAZON_EC2"

read -p "\nChoose a region (${SINGAPORE_REGION}):" REGION
if [[ -z "$REGION" ]]; then
    REGION=$SINGAPORE_REGION
fi

SERVER_LIST_COMMAND="knife ec2 server list --region=${REGION}"

echo -e "\nExecuting ${SERVER_LIST_COMMAND}"

if [[ -z "${SERVER_ID}" ]]; then
    echo -e "\nServer ID not provided. Choose one of the following servers:"
    echo -e "Fetching server list. Please wait..."
    $SERVER_LIST_COMMAND
    echo -e "\n"
    read -p "Server ID: " SERVER_ID
fi

cmd="${SERVER_LIST_COMMAND} | awk '/$SERVER_ID/ {print \$2;}'"
NAME=$(eval $cmd)

SERVER_DELETE_COMMAND="knife ec2 server delete ${SERVER_ID} --purge --region=${REGION}"

echo Server name is $NAME 
echo Are you sure you want to delete the server $NAME? -- THIS CANNOT BE UNDONE! 

read -p "Please type the name of the server: " DELETE_CONFIRMATION

if [ "$DELETE_CONFIRMATION" == "$NAME" ]
then
    echo Killing server $SERVER_ID
    $SERVER_DELETE_COMMAND
    
    if [[ -z "${NAME}" ]]; then
        echo "WARNING: Couldn't find the server name from ${PROVIDER} -- will not touch the node_networking data bag." 
    else
        knife client delete $NAME -y
        knife node delete $NAME -y
        knife data bag delete node_networking $NAME -y 
        knife data bag delete node_users $NAME -y
    fi
else
    echo Not deleting anything, cya!
fi
