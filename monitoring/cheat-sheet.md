# Installation

http://stackoverflow.com/questions/10453828/django-uwsgi-via-nginx-on-ubuntu-11-10

https://bugs.launchpad.net/ubuntu/+source/uwsgi/+bug/954476

http://stackoverflow.com/questions/10748108/nginx-uwsgi-unavailable-modifier-requested-0
yum install uwsgi-plugin-python

mkdir -p /usr/lib/uwsgi/plugins

```sudo pip install -r pip-requires.txt

Apply the django patch for export_poll_data

```patch -p1 < ../../../../../../../ureport/legacy-repo/ureport_project/rapidsms_ureport/12890.Django-1.3.diff

# Monitoring cheat sheet


To get db psql access...
./manage.py dbshell

http://95.138.170.120:8000/polls/createpoll/

Put Tastypie in localsettings.py of the app server

# Start Poll

Puts entries in rapidsms_httprouter_message table which is the Q

Then you need to run ./manage.py sendmessages

To configure logging in this add:

LOGGING = {
 'version' : 1,

 'handlers': {
    'command': {
        'level': 'DEBUG',
        'class': 'logging.FileHandler',
        'filename': './command_log'
     }
 },
 'loggers': {
     'command': {
         'level': 'DEBUG',
         'handlers': ['command']
     }
  }
}

to localsettings.py


http://95.138.170.120:8000/createpoll/

After which it goes to a broken page so to view it, go to /polls

http://95.138.170.120:8000/polls/



http://95.138.170.120:8000/polls/233/view/

See the responses from a poll:


http://95.138.170.120:8000/polls/responses/232/stats/

http://95.138.170.120:8000/admin/poll/response/

# Loading dataset into db

```create database ureport_psql;
```psql -U postgres ureport_prod < ureport.sql

``` rapidsms_contact and rapidsms_connection need the name of the contact and the phone number to be annonymised
Started 10:33

```psql -h hostname -U postgres ureport_perf < ureport_perf.sql

```split -b51200k perf_data.tgz upload/perf_data_gz_

# Exporting a dataset from the db

```pg_dump ureport_perf > ureport_perf.sql

```tar -cvzf ./perf_data.tgz ./ureport_perf.sql


# Useful SQL queries:


Show the number of contacts in each group

   select ag.name, group_id, count(*) as number_in_group from rapidsms_contact_groups as rsmsg inner join auth_group as ag on (rsmsg.group_id =   ag.id) group by group_id, ag.name order by number_in_group ;

Generate a sql script to grant permissions to all tables:

```SELECT 'GRANT ALL ON ' || table_name || ' TO ureport;'  as query FROM information_schema.tables where table_schema='public' ORDER BY table_schema,table_name;

```SELECT 'GRANT ALL ON ' || table_name || ' TO ureport;'  as query FROM information_schema.indexes where index_schema='public' ORDER BY table_schema,table_name;


# PERFORMANCE

context_processors:

Poll.objects.exclude(start_date=None).exclude(pk__in=[297,296,349,350]).order_by('-start_date')[:2

# BUGS

Don't allow a poll to be started if there are no participants!

# Postgress Logging:

You can find out where your postgress is getting its configuration from with the following SQL:

    show config_file;

    show all; #This will show you all the config parameters

Once you have this, you can open it and begin configuring the logging...

On a mac, this is `~/Library/Application Support/Postgres/var/`

tail -f /var/log/postgres/2013-04-30-postgresql.log | egrep '(INSERT|CommitTransaction$|StartTransaction$)'

debug3 - Includes transactions start and commit this is the level you want to see tx's committed


# Useful greps

grep -e 'start-poll' ureport_application.log* | sort
