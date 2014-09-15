currentNodeName = node[:hostname]

puts "Configuring #{currentNodeName} users..."

node_user = Chef::EncryptedDataBagItem.load("node_users", currentNodeName)

#execute "update centos repo" do
#	command "yum check-update"
#	action :run
#end

user node_user['username'] do
  action :modify
  password node_user['password']
end

execute "copy over the public key of the provisioner" do
  command "echo \"#{node_user['provisioner_public_key']}\" >> ~/.ssh/authorized_keys"
  action :run
end

template "/etc/ssh/sshd_config" do
  source "sshd_config.erb"
end

service "ssh" do
  action :reload
end

execute "Setup ssh key pair " do
    command "ssh-keygen -f ~/.ssh/id_rsa -t rsa -q -N ''"
    action :run
    not_if { ::File.exists?("~/.ssh/id_rsa")}
end
