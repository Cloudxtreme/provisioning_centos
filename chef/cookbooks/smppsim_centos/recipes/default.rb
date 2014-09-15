#
# Cookbook Name:: smppsim
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
cookbook_file "/tmp/SMPPSim.tar.gz" do
	source "SMPPSim.tar.gz"
end
execute "untar SMPPSim" do
	cwd "/home/ureport"
	command "tar -xvf /tmp/SMPPSim.tar.gz"
	action :run
end
