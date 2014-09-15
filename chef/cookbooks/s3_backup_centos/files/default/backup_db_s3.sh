pg_dump -U postgres -h localhost ureport > ureport_backup.sql
pg_dump -U postgres -h localhost geoserver > geoserver_backup.sql

s3cmd -c /home/ureport/.s3cfg put ureport_backup.sql s3://ureportdbbackups/"$(hostname)/ureport_$(date).sql"
s3cmd -c /home/ureport/.s3cfg put geoserver_backup.sql s3://ureportdbbackups/"$(hostname)/geoserver_$(date).sql"

rm ureport_backup.sql

rm geoserver_backup.sql