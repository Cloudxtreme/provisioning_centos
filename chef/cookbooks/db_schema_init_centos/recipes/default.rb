directory "/var/log/ureport" do
	action :create
end

execute "Sync database" do
	cwd "/home/ureport/code/ureport/ureport_project"
	command "bash -c 'source /home/ureport/virtualenv/ureport/bin/activate && ./manage.py syncdb --noinput'"
	action :run
end
