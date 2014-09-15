private_key = Chef::EncryptedDataBagItem.load("github_keys", "root_at_ci-server")['key']

directory "/home/ureport/code" do
    mode 0775
    owner "ureport"
    group "ureport"
    action :create
    recursive true
end

cookbook_file "/home/ureport/ssh_wrapper.sh" do
        source "github_ssh_wrapper.sh"
        mode 0555
        action :create
end

template "/home/ureport/github_deploy_key" do
        source "github_deploy_key.erb"
        variables(:private_key => private_key)
        mode 0400
        action :create
end

#execute "Give permissions to the rsa public key" do
#  command "chmod 644 ~/.ssh/id_rsa.pub"
#  action :run
#end



git "/home/ureport/code/configuration" do
        group "ureport"
        repository node['config_url']
        reference "master"
        revision node['config_revision']
        #ssh_wrapper "/home/ureport/ssh_wrapper.sh"
        depth 1
        action :sync
end

