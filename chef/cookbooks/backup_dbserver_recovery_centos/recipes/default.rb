template "/var/lib/postgresql/9.1/main/recovery.conf" do
  source "recovery.conf.erb"
end

execute "Give postgres user all permissions to recovery.conf" do
  command "chmod 777 /var/lib/postgresql/9.1/main/recovery.conf"
  action :run
end

template "/etc/postgresql/9.1/main/postgresql.conf" do
  source "postgresql.conf.erb"
end
directory "/tmp/postgres-async-backup" do 
  mode 00777
  action :create
end
