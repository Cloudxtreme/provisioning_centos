source /home/ureport/virtualenv/ureport/bin/activate
cd /home/ureport/code/ureport/ureport_project
nohup .//manage.py runserver 0.0.0.0:8000 &
tail -f nohup.out
