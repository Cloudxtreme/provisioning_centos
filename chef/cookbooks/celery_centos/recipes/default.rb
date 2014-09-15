#
# Cookbook Name:: celery
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
execute "celery" do
	command "pip install celery"
	#user "ureport"
	action :run
end

