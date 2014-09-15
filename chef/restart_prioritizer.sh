#!/bin/bash
sudo service uwsgi restart
sudo service kannel stop

sudo supervisorctl stop bearerbox smsbox hi_smsc lo_smsc testprioritizer_uwsgi
sudo supervisorctl stop testthrottle_uwsgi testworker_1_uwsgi testworker_2_uwsgi testworker_3_uwsgi testworker_4_uwsgi

ps aux | grep '[p]ython prioritizer' | awk '{print $2}' | sudo xargs kill -9

sudo supervisorctl start bearerbox
sudo supervisorctl start smsbox
sudo supervisorctl start hi_smsc lo_smsc testprioritizer_uwsgi testthrottle_uwsgi
sudo supervisorctl start testworker_1_uwsgi testworker_2_uwsgi testworker_3_uwsgi testworker_4_uwsgi 
