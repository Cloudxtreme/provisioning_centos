dbserver_node = search(:node, "name:#{node.name.sub("backup-dbserver","dbserver")}")[0]
dbserver_ssh_public_key = dbserver_node['ssh_public_key']


execute "Add dbserver ssh public keys to authorized keys" do
  command "sudo echo \"#{dbserver_ssh_public_key}\" >> /root/.ssh/authorized_keys"
  action :run
end
