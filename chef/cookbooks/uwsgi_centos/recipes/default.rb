#%w{uwsgi uwsgi-plugin-python}.each do |pkg|
#	package pkg do
#		action :install
#	end
#end
#Installation Script TO-DO

template "/etc/uwsgi/apps-enabled/ureport.ini" do
  source "ureport.ini.erb"
end

template "/etc/uwsgi/apps-available/ureport.ini" do
  source "ureport.ini.erb"
end

execute "Clean up data Socket dir if it exists" do
  command "rm -rf /var/www/sockets"
  action :run
end

execute "Make data dir" do
  command "mkdir /var/www/sockets"
  action :run
end
service "uwsgi" do
	action :start
end


