jump_box_public_key = Chef::EncryptedDataBagItem.load("public_keys", "jump-box")
nagios_server_public_key = Chef::EncryptedDataBagItem.load("public_keys", "nagios-server")

execute "Add JumpBox to authorized keys" do
  command "echo \"#{jump_box_public_key['public_key']}\" >> ~/.ssh/authorized_keys"
  action :run
end

execute "Add Nagios server to authorized keys" do
  command "echo \"#{nagios_server_public_key['public_key']}\" >> ~/.ssh/authorized_keys"
  action :run
end

template "/etc/ssh/sshd_config" do
  source "sshd_config.erb"
end

service "ssh" do
  action :restart
end
