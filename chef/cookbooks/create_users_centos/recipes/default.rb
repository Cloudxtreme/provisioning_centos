
currentNodeName = Chef::Config[:node_name]

puts "Configuring node #{currentNodeName} users..."

node_user = Chef::EncryptedDataBagItem.load("node_users", currentNodeName)



#Going to ignore the username for now, we can use this later as we are alwasy in as root to begin with

# execute "change node password" do
#   command "echo '#{node_user['username']}:#{node_user['password']}' | chpasswd"
#   action :run
# end

puts "root password is #{node_user['password']}"

#execute "update centos repo" do
#	command "yum check-update"
#	action :run
#end

user "#{node_user['username']}" do
  action :modify
  password "#{node_user['password']}"
end

user "ureport" do
	action :create
	home "/home/ureport"
	system true
	password "$1$.WsplVWP$vZGPs6vxS0FmQ0dh83M541"
end
user "ureport" do
	action :modify
	home "/home/ureport"
	supports :manage_home=>true
end
group "ureport" do
	action :create
	members "ureport"
end
directory "/home/ureport" do
	owner "ureport"
	group "ureport"
	mode "0755"
	action :create
end
