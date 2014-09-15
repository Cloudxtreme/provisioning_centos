performance_test_directory = "/home/ureport/code/performance-tests"
virtualenv_directory = "/home/ureport/virtualenv"

fake_smsc_processes = [
    {"name" => "hi_smsc", "command" => "#{virtualenv_directory}/performance-tests/bin/python smsc-fake.py 2881",
     "directory" => "#{performance_test_directory}/", "log" => "/var/log/smsc-tests/hi-smsc.log", "user" => "ureport"},
    {"name" => "lo_smsc", "command" => "#{virtualenv_directory}/performance-tests/bin/python smsc-fake.py 2880",
     "directory" => "#{performance_test_directory}/", "log" => "/var/log/smsc-tests/lo-smsc.log", "user" => "ureport"},
]

smscs = [
    {"id" => "hi_smsc", "smsc_host" => "127.0.0.1", "smsc_port" => "2881",
     "smsc_user" => "user", "smsc_password" => "pwd"},
    {"id" => "lo_smsc", "smsc_host" => "127.0.0.1", "smsc_port" => "2880",
     "smsc_user" => "user", "smsc_password" => "pwd"}
]
aggregators = []
smscs.each do |smsc|
  aggregators << smsc["id"]
end

directory "/home/ureport/code" do
  action :create
  recursive true
  not_if { File.directory? ('/home/ureport/code') }
end

directory "#{performance_test_directory}" do
  action :delete
  recursive true
  not_if { node.chef_environment == "dev" }
end

git "#{performance_test_directory}" do
  group "ureport"
  repository "git@github.com:ureport/performance-tests.git"
  reference "master"
  revision "HEAD"
  ssh_wrapper "/home/ureport/ssh_wrapper.sh"
  action :sync
  not_if { File.directory? performance_test_directory }
end

execute "Making ureport the owner of performance tests folder" do
  command "chown ureport:ureport #{performance_test_directory}"
  action :run
end

directory "#{virtualenv_directory}" do
  action :create
  recursive true
  not_if { File.directory? ("#{virtualenv_directory}") }
end

execute "create performance-tests virtualenv" do
  cwd "#{virtualenv_directory}/"
  command "virtualenv --no-site-packages performance-tests"
  action :run
end

execute "install pip dependencies" do
  cwd "#{performance_test_directory}/"
  command "bash -c 'source #{virtualenv_directory}/performance-tests/bin/activate && pip install -r pip-requirements.txt'"
  action :run
end

template "/etc/kannel/kannel.conf" do
  source "kannel.test.conf.erb"
  cookbook "kannel"
  variables({
                :receiver => "0000;+0000",
                :smscs => smscs,
                :username => "user",
                :password => "pwd",
                :sms_service_url => "http://127.0.0.1/gearmanthrottle/receive?backend=%i&sender=%p&message=%b",
                :aggregators => aggregators
            })
end

template "/etc/supervisord.conf" do
  source "supervisord.conf.erb"
  variables({
                :processes => fake_smsc_processes
            })
end

directory "/var/log/smsc-tests" do
  owner "ureport"
  group "ureport"
  mode "0755"
  action :create
end

service "kannel" do
  action :stop
end

execute "Update supervisorctl" do
  command "sudo supervisorctl update"
  action :run
end