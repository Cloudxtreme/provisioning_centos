execute "Install supervisord" do
	command "easy_install supervisor"
	action :run
end
template "/etc/supervisord.conf" do
	source "supervisord.conf.erb"
end

template "/etc/init.d/supervisord" do
	source "supervisord.erb"
end
file "/etc/init.d/supervisord" do
	mode "0755"
	action :touch
end
directory "/var/log/supervisor" do
	owner "ureport"
	group "ureport"
	mode "0755"
	action :create
end
service "supervisord" do
	action :start
end
