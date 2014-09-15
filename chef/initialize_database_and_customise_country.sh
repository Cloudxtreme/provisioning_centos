#!/bin/bash

echo -e "\n1.Initialising an empty database on db_server ...\n\n2.Customising registration messages,locations.\n"

APPSERVER_NODE_NAME=$1
APPSERVER_SSH_USER=$2
APPSERVER_SSH_PASSWORD=$3

knife ssh name:${APPSERVER_NODE_NAME} -a ipaddress -x ${APPSERVER_SSH_USER} -P ${APPSERVER_SSH_PASSWORD} "chef-client -o 'role[init_db],role[customise_application]' --once"

# Restart geoserver tomcat so that it connects to the db
knife ssh name:${APPSERVER_NODE_NAME} -a ipaddress -x ${APPSERVER_SSH_USER} -P ${APPSERVER_SSH_PASSWORD} "service tomcat7 restart"

# Restart uWSGI so the customised content is picked up 
knife ssh name:${APPSERVER_NODE_NAME} -a ipaddress -x ${APPSERVER_SSH_USER} -P ${APPSERVER_SSH_PASSWORD} "service uwsgi restart"

echo " "
