include_recipe "java_centos::openjdk"

directory "/home/ureport/ibm" do
	owner "ureport"
	action :create
end

cookbook_file "/home/ureport/ibm/ibm_messageclassifier.tar.gz" do
	action :create
end

cookbook_file "/home/ureport/ibm/cronjob.sh" do
	action :create
	mode "0755"
	owner "ureport"
end

execute "untar contents of IBM message classifier" do
	command "tar xzvf ibm_messageclassifier.tar.gz"
	cwd "/home/ureport/ibm"
	action :run
end

#cron "run_message_classifier" do
#	minute "0"
#	hour "0"
#	user "ureport"
#	command "bash -c /home/ureport/ibm/cronjob.sh"
#	action :create
#end
