execute "Create Superuser" do
    cwd "/home/ureport/code/ureport/ureport_project"
    command "bash -c 'source /home/ureport/virtualenv/ureport/bin/activate && ./manage.py createsuperuser --username=ureport --email=a@a.com --noinput' "
    action :run
end
