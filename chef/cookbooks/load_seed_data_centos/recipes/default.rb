execute "Load ussd" do
    cwd "/home/ureport/code/ureport/ureport_project"
    command "bash -c 'source /home/ureport/virtualenv/ureport/bin/activate && ./manage.py loaddata ussd'"
    action :run
end

execute "Insert dummy messages for IBM Classifier" do
    cwd "/home/ureport/code/ureport/ureport_project"
    command "bash -c 'source /home/ureport/virtualenv/ureport/bin/activate && ./manage.py load_ibm_seed_data'"
    action :run
end
