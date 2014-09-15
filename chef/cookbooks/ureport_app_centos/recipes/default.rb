directory "/var/www" do
  action :create
  not_if {File.directory? ('/var/www')}
end

directory "/var/log/ureport" do
  action :create
  not_if {File.directory? ('/var/log/ureport')}
end

directory "/var/log/uwsgi/app" do
  action :create
  recursive true
end

directory "/home/ureport/code" do
	mode 0775
	owner "ureport"
	group "ureport"
	action :create
end

directory "/home/ureport/code/ureport" do
    action :delete
    recursive true
    not_if {node.chef_environment == "dev"}
end

git "/home/ureport/code/ureport" do
	group "ureport"
	repository node['app_repository_url']
	reference "master"
    revision node['app_revision']
    enable_submodules true
    depth 1
	action :sync
end

%w{graphviz}.each do |pkg|
      package pkg do
        action :install
      end
end

execute "Install graphviz-devel.x86_64" do
	command "yum install -y graphviz-devel.x86_64"
	action :run
end

execute "install pip dependencies" do
	cwd "/home/ureport/code/ureport/"
	command "bash -c 'source /home/ureport/virtualenv/ureport/bin/activate && pip install -r pip-requires.txt'"
	action :run
end

execute "patch django" do
  	command "patch -p2 -d /home/ureport/virtualenv/ureport/lib/python2.7/site-packages/django < rapidsms_ureport/patch_for_export_poll.Django-1.3.diff -t -N >> /var/log/ureport/django_patch.log | echo 'patch applied'"
  	cwd "/home/ureport/code/ureport/ureport_project/"
  	action :run
end

link "/home/ureport/code/ureport/ureport_project/media" do
  to "/home/ureport/virtualenv/ureport/lib/python2.7/site-packages/django/contrib/admin/media"
end

link "/var/www/ureport" do
  to "/home/ureport/code/ureport"
end

cookbook_file "useful-scripts.tgz" do
  path "/root/useful-scripts.tgz"
  action :create
end

execute "Unpack Scripts" do
  command "cd /root;tar xzvf useful-scripts.tgz"
end

include_recipe "country_customisations_centos::customise_localsettings"
