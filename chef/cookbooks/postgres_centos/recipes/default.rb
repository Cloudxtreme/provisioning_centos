execute "Create default locales for postgres server to use when starting" do
  command "export LANGUAGE=en_US.UTF-8 && export LANG=en_US.UTF-8 && export LC_ALL=en_US.UTF-8"
  action :run
end

execute 'Update PATH environment variable' do
  command 'echo "export PATH=$PATH:/usr/pgsql-9.1/bin" >> /root/.bashrc'
  action :run
end

execute 'Source PATH environment variable' do
  command "bash -c 'source /root/.bashrc'"
  action :run
end

execute "Register Postgres Package" do
	command "rpm -ivh http://yum.postgresql.org/9.1/redhat/rhel-6.5-x86_64/pgdg-centos91-9.1-4.noarch.rpm"
	not_if { File.exist?("/var/lib/pgsql") }
	action :run
end

#%w{postgresql-9.1 postgis postgresql-9.1-postgis}.each do |pkg|
#%w{postgresql91-server postgis2_91}
%w{postgresql91-server postgresql-devel}.each do |pkg|
  package pkg do
    action :install
  end
end

execute "Initialize Database" do
	command "service postgresql-9.1 initdb"
	not_if "service postgresql-9.1 status"
	action :run
end

template "/var/lib/pgsql/9.1/data/pg_hba.conf" do
  source "pg_hba.conf.erb"
end

execute "Create directory for storing postgres backup files" do
  command "mkdir -p /tmp/postgres-async-backup"
  action :run
  not_if { File.exist?("/tmp/postgres-async-backup") }
end

execute "Create directory for storing postgres proc" do
	command "mkdir /var/run/postgresql"
	action :run
	not_if { File.exist?("/var/run/postgresql") }
end

execute "Grant permissions to directory" do
	command "chown -R postgres:postgres /var/run/postgresql"
	action :run
end

execute "Grant postgres user all permissions to backup files dir" do
  command "chmod -R 777 /tmp/postgres-async-backup/"
  action :run
end

template "/var/lib/pgsql/9.1/data/postgresql.conf" do
  source "postgresql.conf.erb"
end

execute "Starting Database" do
	command "service postgresql-9.1 start"
	action :run
end

execute "Create empty database" do
	command "createdb ureport"
	user "postgres"
	not_if "psql --list | grep ureport", :user => 'postgres'
	action :run
end
