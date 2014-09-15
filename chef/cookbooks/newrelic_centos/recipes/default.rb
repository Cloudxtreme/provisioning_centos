newrelic = Chef::EncryptedDataBagItem.load("license","newrelic")
license = newrelic["license"]
execute "newrelic update debian repo" do
	command "wget -O /etc/apt/sources.list.d/newrelic.list http://download.newrelic.com/debian/newrelic.list"
	action :run
end
execute "add authentication keys" do
	command "apt-key adv --keyserver hkp://subkeys.pgp.net --recv-keys 548C16BF"
	#command "apt-key adv --keyserver hkp://subkeys.pgp.net --recv-keys 548C16BF && yum check-update"
	action :run
end
package "newrelic-sysmond" do
	action :install
end

execute "newrelic authentication" do
	command "nrsysmond-config --set license_key=#{license}"
	action :run
end
service "newrelic-sysmond" do
	action :start
end
