cookbook_file "SMPPSim.tar.gz" do
        path "/home/ureport/SMPPSim.tar.gz"
end
execute "Unzip gzipped tarball" do
	cwd "/home/ureport"
	command "gunzip SMPPSim.tar.gz"
	action :run
end

execute "Untar tarball" do
	cwd "/home/ureport"
	command "tar xvf SMPPSim.tar"
	action :run
end
template "/home/ureport/SMPPSim/conf/smppsim.props" do
	source "smppsim.props.erb"
end
file "/home/ureport/SMPPSim/startsmppsim.sh" do
	group "ureport"
	mode "0755"
	action :touch
end
execute "start smppsim" do
	cwd "/home/ureport/SMPPSim/"
	command "nohup sh startsmppsim.sh &"
	action :run
end
