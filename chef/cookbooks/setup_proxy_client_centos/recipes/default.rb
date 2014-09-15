proxy_servers = search(:node, "role:proxy")
main_proxy_server_ip = proxy_servers[-1].rackspace.private_ip

template "/etc/environment" do
	source "environment.erb"

	variables(
		:proxy_server_ip => main_proxy_server_ip,
	)

end

execute "sourcing the /etc/environment file" do
	command "bash -c 'source /etc/environment'"
	action :run
end
