prioritizer_directory = "/home/ureport/code/prioritizer"
chef_env = node.chef_environment
kannel_credentials = Chef::EncryptedDataBagItem.load("kannel_credentials", chef_env)

smscs = kannel_credentials['smscs']
aggregators = []
smscs.each do |smsc|
  aggregators << smsc["id"]
end

directory "/home/ureport/code" do
  action :create
  recursive true
  not_if {File.directory? ('/home/ureport/code')}
end

directory "#{prioritizer_directory}" do
  action :delete
  recursive true
  not_if { node.chef_environment == "dev" }
end

git "#{prioritizer_directory}" do
  group "ureport"
  repository "git@github.com:unicefuganda/prioritizer.git"
  reference "master"
  revision "HEAD"
  ssh_wrapper "/home/ureport/ssh_wrapper.sh"
  action :sync
  not_if { File.directory? prioritizer_directory}
end

cookbook_file "settings.py" do
  path "#{prioritizer_directory}/settings.py"
  owner "ureport"
  group "ureport"
  mode  "0755"
  action :create
end

directory "/home/ureport/virtualenv" do
  action :create
  recursive true
  not_if {File.directory? ('/home/ureport/virtualenv')}
end

execute "create prioritizer virtualenv" do
  cwd "/home/ureport/virtualenv"
  command "virtualenv --no-site-packages prioritizer"
  action :run
end

execute "install pip dependencies" do
  cwd "#{prioritizer_directory}/"
  command "bash -c 'source /home/ureport/virtualenv/prioritizer/bin/activate && pip install -r pip-requirements.txt'"
  action :run
end

package "gearman" do
  action :install
end

execute "Download redis" do
  command "wget -O /root/redis-2.8.9.tar.gz http://download.redis.io/releases/redis-2.8.9.tar.gz"
  action :run
end

execute "Unzip redis" do
  cwd     "/root"
  command "tar -xzvf redis-2.8.9.tar.gz"
  action :run
end

execute "Make redis" do
  cwd     "/root/redis-2.8.9"
  command <<-EOF
          make distclean
          make
          make test
          make install
  EOF
  action :run
end

cookbook_file "redis.args" do
  path "/root/redis.args"
  owner "ureport"
  group "ureport"
  mode  "0755"
  action :create
end

execute "Install redis" do
  command "sh /root/redis-2.8.9/utils/install_server.sh n < /root/redis.args"
  action :run
end

directory "/var/log/prioritizer" do
  owner "ureport"
  group "ureport"
  mode "0755"
  action :create
end

template "/etc/supervisord.conf" do
  source "supervisord.conf.erb"
  owner "ureport"
  group "ureport"
  mode  "0755"
end

template "/etc/nginx/conf.d/ureport-server.conf" do
  source "ureport-server.conf.erb"
  owner "ureport"
  group "ureport"
  mode  "0755"
end

template "/etc/kannel/kannel.conf" do
  source "kannel.test.conf.erb"
  cookbook "kannel"
  variables({
                :receiver  => kannel_credentials['receiver'],
                :smscs => smscs,
                :username  => kannel_credentials['username'],
                :password  => kannel_credentials['password'],
                :sms_service_url => "http://127.0.0.1/gearmanthrottle/receive?backend=%i&sender=%p&message=%b",
                :aggregators => aggregators
            })
end

service "kannel" do
  action :stop
end

execute "Update supervisorctl" do
  command "sudo supervisorctl update"
  action :run
end

service "nginx" do
  action :restart
end
