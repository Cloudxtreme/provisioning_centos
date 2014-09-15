chef_env = node.chef_environment

kannel_credentials = Chef::EncryptedDataBagItem.load("kannel_credentials", chef_env)

smscs = kannel_credentials['smscs']
aggregators = []
smscs.each do |smsc|
    aggregators << smsc["id"]
end

package "kannel" do
	action :install
end

template "/etc/kannel/kannel.conf" do
  source "kannel.test.conf.erb"
  variables({
	:receiver  => kannel_credentials['receiver'],
    :smscs => smscs,
    :username  => kannel_credentials['username'],
    :password  => kannel_credentials['password'],
    :sms_service_url => "http://kannel.ureport.org/router/receive?password=k1pr0t1ch&backend=%i&sender=%p&message=%b",
    :aggregators => aggregators
  })
end

service "kannel" do
	action :stop
end
