#execute "update repositories" do
#	command "yum check-update"
#	action :run
#end

%w{nagios3 nagios-nrpe-plugin nagios-plugins}.each do |pkg|
      package pkg do
        action :install
      end
end

execute "creating nagiosadmin user" do
	command "htpasswd -c -b /etc/nagios3/htpasswd.users nagiosadmin nagiosadmin@ureport"
	action :run
end

execute "Setup ssh key pair" do
    command "ssh-keygen -f /var/lib/nagios/.ssh/id_rsa -t rsa -q -N ''"
    user "nagios"
    action :run
    not_if { ::File.exists?("/var/lib/nagios/.ssh/id_rsa")}
end

