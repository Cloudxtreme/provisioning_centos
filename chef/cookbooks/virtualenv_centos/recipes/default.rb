#
# Cookbook Name:: virtualenv
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
%w{build-essential python-setuptools python-dev}.each do |pkg|
      package pkg do
        action :install
      end
end

execute "pip" do
	command "easy_install pip"
	user "root"
end

execute "virtualenv" do
	command "pip install virtualenv"
end

directory "/home/ureport/virtualenv" do
	owner "ureport"
	group "ureport"
	action :create
end 

execute "create_virtualenv" do
	cwd "/home/ureport/virtualenv/"
	command "virtualenv --no-site-packages ureport"
end


