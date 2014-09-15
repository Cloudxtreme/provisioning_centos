db_servers = search(:node, "role:db_server AND NOT chef_environment:dev")
backup_db_servers = search(:node, "role:backup_db_server AND NOT chef_environment:dev")


#execute "update centos repo" do
#	command "yum check-update"
#	action :run
#end

package "squid" do
	action :install
end

template "/etc/squid3/squid.conf" do
  source "squid.conf.erb"
	servers = db_servers + backup_db_servers
	variables(
		:servers => servers,
	)
end

service "squid3" do
	action :restart
end

