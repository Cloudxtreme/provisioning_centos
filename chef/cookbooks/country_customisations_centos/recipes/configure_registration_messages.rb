include_recipe "country_customisations_centos::clone_configuration_repo"

execute "configure registration messages from messages file" do
	command "/home/ureport/virtualenv/ureport/bin/python manage.py configure_registration_scripts /home/ureport/code/configuration/messages.txt"
	cwd "/home/ureport/code/ureport/ureport_project"
	action :run
end

execute "load EAV attributes" do
	command "/home/ureport/virtualenv/ureport/bin/python manage.py loaddata eav_attributes"
	cwd "/home/ureport/code/ureport/ureport_project"
	action :run
end

execute "Load locations for Uganda ONLY" do
    cwd "/home/ureport/code/ureport/ureport_project"
    command "bash -c 'source /home/ureport/virtualenv/ureport/bin/activate && ./manage.py loaddata locations'"
    action :run
	only_if { [ "uganda-prod", "dev" ].include? node.chef_environment }
end

execute "load locations from CSV file" do
	command "/home/ureport/virtualenv/ureport/bin/python manage.py import_csv_locations /home/ureport/code/configuration/locations.csv 0"
	cwd "/home/ureport/code/ureport/ureport_project"
	action :run
end

execute "load country-specific static assets" do
	command "cp -R /home/ureport/code/configuration/static_assets/* /home/ureport/code/ureport/ureport_project/"
	cwd "/home/ureport/code/"
	action :run
end

execute "load gender rules" do
    command "/home/ureport/virtualenv/ureport/bin/python manage.py load_gender_rules /home/ureport/code/configuration/gender_rules.yaml"
    cwd "/home/ureport/code/ureport/ureport_project"
    action :run
    only_if { File.exists? "/home/ureport/code/configuration/gender_rules.yaml" }
end
