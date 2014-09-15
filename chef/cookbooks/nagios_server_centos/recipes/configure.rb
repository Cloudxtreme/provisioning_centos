app_servers = search(:node, "role:app_server AND NOT chef_environment:*dev")
db_servers = search(:node, "role:db_server AND NOT chef_environment:*dev")
backup_db_servers = search(:node, "role:backup_db_server AND NOT chef_environment:*dev")

execute "wiping out all existing Nagios config files" do
        command "rm /etc/nagios3/conf.d/*.cfg"
        action :run
end

cookbook_file "/etc/nagios-plugins/config/check_via_ssh.cfg" do
	source "check_via_ssh.cfg"
	mode "0644"
	action :create
end

cookbook_file "/etc/nagios3/conf.d/services_nagios2.cfg" do
	source "services_nagios2.cfg"
	mode "0644"
	action :create
end

cookbook_file "/etc/nagios3/conf.d/contacts_nagios2.cfg" do
	source "contacts_nagios2.cfg"
	mode "0644"
	action :create
end

cookbook_file "/etc/nagios3/conf.d/generic-host_nagios2.cfg" do
	source "generic-host_nagios2.cfg"
	mode "0644"
	action :create
end

cookbook_file "/etc/nagios3/conf.d/generic-service_nagios2.cfg" do
	source "generic-service_nagios2.cfg"
	mode "0644"
	action :create
end

cookbook_file "/etc/nagios3/conf.d/timeperiods_nagios2.cfg" do
	source "timeperiods_nagios2.cfg"
	mode "0644"
	action :create
end

template "/etc/nagios3/conf.d/hostgroups_nagios2.cfg" do
	source "hostgroups_nagios2.cfg.erb"
	variables(:appservers => app_servers, :dbservers => db_servers, :backupdbservers => backup_db_servers)
	mode "0644"
	action :create
end

app_servers.each do |server|
	template "/etc/nagios3/conf.d/#{server.name}.cfg" do
		source "host.cfg.erb"
		variables(:server => server)
		mode "0644"
		action :create
	end
end

db_servers.each do |server|
	template "/etc/nagios3/conf.d/#{server.name}.cfg" do
		source "host.cfg.erb"
		variables(:server => server)
		mode "0644"
		action :create
	end
end

backup_db_servers.each do |server|
	template "/etc/nagios3/conf.d/#{server.name}.cfg" do
		source "host.cfg.erb"
		variables(:server => server)
		mode "0644"
		action :create
	end
end

service "nagios3" do
  action :restart
end
