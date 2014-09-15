cron "check_script_progress" do
    command "/home/ureport/virtualenv/ureport/bin/python /home/ureport/code/ureport/ureport_project/manage.py check_script_progress -e 0 -l 23 > /var/log/ureport/check_script_progress.log 2>&1; echo \"Exit code: $?\" >> /var/log/ureport/check_script_progress.log"
    action :create
end
cron "export_contacts" do
	command "/home/ureport/virtualenv/ureport/bin/python /home/ureport/code/ureport/ureport_project/manage.py export_contacts > /var/log/ureport/export_contacts.log 2>&1; echo \"Exit code: $?\" >> /var/log/ureport/export_contacts.log"
	minute "01"
	hour "21"
	action :create	
end
cron "export_poll_data" do
    command "/home/ureport/virtualenv/ureport/bin/python /home/ureport/code/ureport/ureport_project/manage.py export_poll_data > /var/log/ureport/export_poll_data.log 2>&1; echo \"Exit code: $?\" >> /var/log/ureport/export_poll_data.log"
    minute "07"
    action :create
end
