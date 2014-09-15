package "ufw"

execute "enable" do
  command "echo yes | ufw enable"
end

execute "ssh" do
  command "ufw allow in on eth1 to any port ssh"
end

node['open_ports'].keys.each do |interface|
  node['open_ports'][interface].each do |port|
    execute "Allow #{port} on #{interface}." do
      command "ufw allow in on #{interface} to any port #{port}"
    end
  end
end
