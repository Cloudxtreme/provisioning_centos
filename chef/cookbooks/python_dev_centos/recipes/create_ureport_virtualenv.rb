directory "/home/ureport/virtualenv" do
    owner "ureport"
    group "ureport"
    not_if { node.attribute?("virtualenv_created") }
    action :create
end

execute "create_virtualenv" do
    cwd "/home/ureport/virtualenv/"
    command "virtualenv --no-site-packages ureport"
    not_if { node.attribute?("virtualenv_created") }
end

ruby_block "Set virtualenv_created flag" do
    block do
        node.set['virtualenv_created'] = true
    end
end

