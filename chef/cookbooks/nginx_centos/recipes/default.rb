#
# Cookbook Name:: nginx
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
package "nginx" do
	action :install
end


template "/etc/nginx/nginx.conf" do
  source "nginx.conf.erb"
end


template "/etc/nginx/conf.d/ureport-server.conf" do
  source "ureport-server.conf.erb"
end

service "nginx" do
  action :restart
end