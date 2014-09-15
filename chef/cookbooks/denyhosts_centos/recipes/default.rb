execute "Adding Repository for Denyhosts" do
	command "rpm -ivh http://mirror.metrocast.net/fedora/epel/6/i386/epel-release-6-8.noarch.rpm"
	action :run
end

execute "Run installation of denyhosts" do
	command "yum -y install denyhosts"
	action :run
end

jumpbox_nodename = 'jump-box'
jumpboxes = search(:node, "name:#{jumpbox_nodename}")

template "/etc/hosts.allow" do
	source "hosts.allow.erb"
	variables(:jumpboxes => jumpboxes)
	action :create
	mode "0644"
end

service "denyhosts" do
	action :restart
end