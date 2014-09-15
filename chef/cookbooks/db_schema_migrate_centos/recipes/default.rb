execute "Migrate db" do
	cwd "/home/ureport/code/ureport/ureport_project"
	command "bash -c 'source /home/ureport/virtualenv/ureport/bin/activate && ./manage.py migrate'"
	action :run
end
