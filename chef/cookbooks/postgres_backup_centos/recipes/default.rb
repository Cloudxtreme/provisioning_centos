execute "Create default locales for postgres server to use when starting" do
  command "export LANGUAGE=en_US.UTF-8 && export LANG=en_US.UTF-8 && export LC_ALL=en_US.UTF-8 && locale-gen en_US.UTF-8 && dpkg-reconfigure locales"
  action :run
end

%w{postgresql-9.1 postgis postgresql-9.1-postgis}.each do |pkg|
  package pkg do
    action :install
  end
end

template "/etc/postgresql/9.1/main/pg_hba.conf" do
  source "pg_hba.conf.erb"
end

template "/etc/postgresql/9.1/main/postgresql.conf" do
  source "postgresql.conf.erb"
end

service "postgresql" do
  action :restart
end

