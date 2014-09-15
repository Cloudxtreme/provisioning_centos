DB_SERVER_NODE_NAME=$1
DB_SERVER_USER=$2
DB_SERVER_PASSWORD=$3
BACKUP_DBSERVER_NODE_NAME=$4
BACKUP_DBSERVER_USER=$5
BACKUP_DBSERVER_PASSWORD=$6

knife ssh name:${DB_SERVER_NODE_NAME} -a ipaddress -x ${DB_SERVER_USER} -P ${DB_SERVER_PASSWORD} "yum install sshpass"
knife ssh name:${DB_SERVER_NODE_NAME} -a ipaddress -x ${DB_SERVER_USER} -P ${DB_SERVER_PASSWORD} "psql -c \"SELECT pg_start_backup('label', true)\" -U postgres -h localhost"
knife ssh name:${DB_SERVER_NODE_NAME} -a ipaddress -x ${DB_SERVER_USER} -P ${DB_SERVER_PASSWORD} "psql -c \"SELECT pg_stop_backup()\" -U postgres -h localhost"
knife ssh name:${BACKUP_DBSERVER_NODE_NAME} -a ipaddress -x ${BACKUP_DBSERVER_USER} -P ${BACKUP_DBSERVER_PASSWORD} "sudo chef-client -o 'recipe[backup_dbserver_recovery]' --once"
knife ssh name:${BACKUP_DBSERVER_NODE_NAME} -a ipaddress -x ${BACKUP_DBSERVER_USER} -P ${BACKUP_DBSERVER_PASSWORD} "sudo service postgresql stop"
knife ssh name:${DB_SERVER_NODE_NAME} -a ipaddress -x ${DB_SERVER_USER} -P ${DB_SERVER_PASSWORD} "sudo service postgresql stop"
knife ssh name:${DB_SERVER_NODE_NAME} -a ipaddress -x ${DB_SERVER_USER} -P ${DB_SERVER_PASSWORD} "sshpass -p ${BACKUP_DBSERVER_PASSWORD} rsync -a /var/lib/postgresql/9.1/main/ root@backup.ureport.org:/var/lib/postgresql/9.1/main/ --exclude postmaster.pid -e \"ssh -o StrictHostKeyChecking=no\""
knife ssh name:${BACKUP_DBSERVER_NODE_NAME} -a ipaddress -x ${BACKUP_DBSERVER_USER} -P ${BACKUP_DBSERVER_PASSWORD} "sudo service postgresql start"
knife ssh name:${DB_SERVER_NODE_NAME} -a ipaddress -x ${DB_SERVER_USER} -P ${DB_SERVER_PASSWORD} "sudo service postgresql start"
