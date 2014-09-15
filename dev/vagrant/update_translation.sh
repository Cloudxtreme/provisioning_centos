#!/bin/bash

STARTING_DIR=`pwd`
CODE_LOCATION="/home/ureport/code/ureport/ureport_project/"
PYTHON="${VIRTUAL_ENV}/bin/python" 

#Activate virtual env
source "${VIRTUAL_ENV}/bin/activate"

cd $CODE_LOCATION

rm ${CODE_LOCATION}locale/fake_language/LC_MESSAGES/django.po
$PYTHON manage.py makemessages -l fake_language
$PYTHON manage.py makemessages -l fake_language -d djangojs -i *.min.js

cd -

$PYTHON setup_fake_language.py "${CODE_LOCATION}locale/fake_language/LC_MESSAGES/django.po"
$PYTHON setup_fake_language.py "${CODE_LOCATION}locale/fake_language/LC_MESSAGES/djangojs.po"

cd $CODE_LOCATION

$PYTHON manage.py compilemessages

cd $STARTING_DIR

service uwsgi restart
