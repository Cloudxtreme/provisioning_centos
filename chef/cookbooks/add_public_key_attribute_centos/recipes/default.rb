execute "generate ssh keys" do
  command "ssh-keygen -t rsa -q -f /root/.ssh/id_rsa -P \"\""
  action :run
  not_if { ::File.exists?("/root/.ssh/id_rsa")}
end

ruby_block "Store the public key" do
  block do
    f = File.open("/root/.ssh/id_rsa.pub")
    public_key = f.read.strip!

    node.set['ssh_public_key'] = public_key
  end
end
