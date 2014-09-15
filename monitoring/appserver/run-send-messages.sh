source /home/ureport/virtualenv/ureport/bin/activate
cd /home/ureport/code/ureport/ureport_project
nohup ./manage.py send_messages > send_messages.log &
tail -f send_messages.log
