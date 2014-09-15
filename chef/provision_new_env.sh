#!/bin/bash

set -e

if [[ -z "$1" ]];
then
    BLOCK_PASSWORD_ACCESS="y"
else
    BLOCK_PASSWORD_ACCESS=$1
fi


read -p "Name prefix (e.g. chris-): " NAME_PREFIX

echo -e " "
read -p "Environment (e.g. dev, south-sudan-prod, ci etc): " ENVIRONMENT

if [[ -z "${ENVIRONMENT}" ]]; then
    echo -e "\nERROR: You must pass in an environment.'\n"
    exit -1
fi

echo -e " "
read -p "Flavour of the boxes to be provisioned (default '4' -- 2GB Standard Instance): " FLAVOUR

if [[ -z "${FLAVOUR}" ]]; then
    FLAVOUR=4
fi

echo Going to provision a $ENVIRONMENT environment with flavour $FLAVOUR boxes...

APPSERVER_SSH_USER="root"

if [ -z "$APPSERVER_SSH_PASSWORD" ]; then
read -s -p "App server root Password: " APPSERVER_SSH_PASSWORD
fi

echo -e " "
DBSERVER_SSH_USER="root"
if [ -z "$DBSERVER_SSH_PASSWORD" ]; then
read -s -p "Db server root Password: " DBSERVER_SSH_PASSWORD
fi
echo -e " "
read -p "Would you like to create a backup db server? (y/n)" SETUP_DB_SERVER_FLAG > /dev/null

if [ "$SETUP_DB_SERVER_FLAG" == "y" ]
then
    read -p "Would you like to create a persistent backup in the cloud? (y/n)" SETUP_PERSISTENT_BACKUP_FLAG > /dev/null
    echo Going to provision backup db server...
    BACKUP_DBSERVER_USER="root"
    if [ -z "$BACKUP_DBSERVER_PASSWORD" ]; then
    read -s -p "Db backup server Password: " BACKUP_DBSERVER_PASSWORD
    fi
    
    ./spawn_env.sh "${NAME_PREFIX}" "${ENVIRONMENT}" "${APPSERVER_SSH_USER}" "${APPSERVER_SSH_PASSWORD}" "${DBSERVER_SSH_USER}" "${DBSERVER_SSH_PASSWORD}" "${BLOCK_PASSWORD_ACCESS}" "${FLAVOUR}" "${SETUP_DB_SERVER_FLAG}" "${SETUP_PERSISTENT_BACKUP_FLAG}" "${BACKUP_DBSERVER_USER}" "${BACKUP_DBSERVER_PASSWORD}"

else
    ./spawn_env.sh "${NAME_PREFIX}" "${ENVIRONMENT}" "${APPSERVER_SSH_USER}" "${APPSERVER_SSH_PASSWORD}" "${DBSERVER_SSH_USER}" "${DBSERVER_SSH_PASSWORD}" "${BLOCK_PASSWORD_ACCESS}" "${FLAVOUR}"

fi 
