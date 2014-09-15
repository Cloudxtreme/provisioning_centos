#!/bin/bash

KEY=$1
SERVER=$2

echo "Uploading your ssh key [${KEY}] to server [${SERVER}] (Must be in your ssh config)"

cat ${KEY} | ssh ${SERVER} 'cat - >> ~/.ssh/authorized_keys'

