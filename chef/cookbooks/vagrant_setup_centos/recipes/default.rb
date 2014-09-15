group "ureport" do
        action :modify
        members "vagrant"
end

directory "/home/ureport/code/ureport" do
  owner "ureport"
  group "ureport"
  mode 00744
  recursive true
  action :create
end

execute "Create directory for storing certificates .ssh" do
  command "mkdir /root/.ssh"
  action :run
  not_if { File.exist?("/root/.ssh") }
end

#execute "Add to sudoers file vagrant" do
#	command "echo 'vagrant ALL=(ALL) ALL' >> /etc/sudoers"
#	action :run
#end


execute "chmod 755 on /root and 600 on .ssh TEMPORARILY since some recipes are dumping stuff there" do
  command "chmod -R 755 /root && chmod -R 600 /root/.ssh"
  action :run
end

cookbook_file "/etc/hosts_vagrant" do
  source "hosts"
  action :create
end

execute "Append U-report stuff to hosts" do
  command "cat /etc/hosts_vagrant >> /etc/hosts"
  action :run
end
