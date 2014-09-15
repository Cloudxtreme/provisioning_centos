#!/bin/bash

SERVER_IP=$1
if [[ -z "${SERVER_IP}" ]]; then
    echo "Usage: ./check_deployed_app <domain name> "
    exit -1
fi

RETURN_CODE=0

function check_url(){

local SERVER_PATH=$1
local INVERT_RESULT=$2
local URL="http://${SERVER_IP}${SERVER_PATH}"
curl -f -s  http://$SERVER_IP$SERVER_PATH > /dev/null

EXIT_STATUS=$?
RED="\e[1;31m"
GREEN="\e[1;32m"
FAILED_MESSAGE="Failed"
SUCCESSFUL_MESSAGE="Successful"
if [ "$INVERT_RESULT" == "Y" ]
then
RED="\e[1;32m"
GREEN="\e[1;31m"
FAILED_MESSAGE="Successful"
SUCCESSFUL_MESSAGE="Failed"

fi
if [ $EXIT_STATUS -ne 0 ]
then
    if [[ -z "${INVERT_RESULT}" ]];
    then
        RETURN_CODE=1
    fi
	printf "${RED}[${FAILED_MESSAGE}] \e[m ${URL} \n\n";
else
	printf "${GREEN}[${SUCCESSFUL_MESSAGE}] \e[m  ${URL} \n\n"
fi

}

printf "Check Home page\n"
check_url "/"

printf "Check Login page\n"
check_url "/accounts/login"

printf "Check polls\n"
check_url "/polls"

printf "Checking Django Admin\n"
check_url "/admin"

printf "Checking supervisor dashboard\n"
check_url "/supervisor"

printf "Checking Geoserver\n"
check_url "/geoserver/"

printf "Checking that static files can be accessed\n"
check_url "/static/ureport/images/banner.png"

printf "Checking that we get a 404 for request on a fake url\n"
check_url "/fakeurl" Y

exit $RETURN_CODE
