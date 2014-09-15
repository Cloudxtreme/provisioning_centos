#!/bin/bash

VIRTUALENV_ACTIVATE="${UREPORT_VIRTUAL_ENV_HOME}/bin/activate"

SCRIPT_PATH="`pwd`"
SCRIPT_NAME=$1
SETTINGS=$2
SCRIPT_ARGS=$3

echo "Going to run a script..."


cd ${UREPORT_HOME}

bash -c "source ${VIRTUALENV_ACTIVATE} && ./ci-start-celery.sh ${SETTINGS}"  

sleep 2 

cd ureport_project

bash -c "${SCRIPT_PATH}/${SCRIPT_NAME} ${SCRIPT_ARGS}"   


cd ..

bash -c "source ${VIRTUALENV_ACTIVATE} && ./ci-stop-celery.sh ${SETTINGS}"   

cd -

echo "Script completed."
