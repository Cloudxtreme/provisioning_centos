
currentNodeName = Chef::Config[:node_name]

puts "Configuring node [#{currentNodeName}] networking..."

node_networking = Chef::EncryptedDataBagItem.load("node_networking", currentNodeName)

puts "appserverNode: #{node_networking['appserver_node']}"
puts "dbserverNode: #{node_networking['dbserver_node']}"
puts "\n\n\n#{node_networking.to_hash}\n\n\n\n"
backup_dbserver_ip = "NO_BACKUP_SERVER"

appserver_ip = search(:node, "name:#{node_networking['appserver_node']}").first[:cloud][:private_ips][0]
dbserver_ip = search(:node, "name:#{node_networking['dbserver_node']}").first[:cloud][:private_ips][0]

if node_networking.to_hash().has_key?('backup_dbserver_node')
	backup_dbserver_ip = search(:node, "name:#{node_networking['backup_dbserver_node']}").first[:cloud][:private_ips][0]
end

template "/etc/hosts_ureport" do
  source "hosts.erb"
  variables(
    :appserver_ip => appserver_ip,
    :dbserver_ip => dbserver_ip,
    :backup_dbserver_ip => backup_dbserver_ip
  )
end

execute "Backup hosts" do
  command "cp /etc/hosts /etc/hosts_installed"
  action :run
end

execute "Backup hosts" do
  command "cat /etc/hosts_ureport >> /etc/hosts"
  action :run
end

