def valid_options
    {
        "node-name" => {:dbserver => "servername-dbserver", :appserver => "servername-appserver"}
    }
end

def valid_parameters
    {
        "appserver"=> {"ssh_user"=>"ssh_user_test", "ssh_password" => "password_test", "ssh_password_sha" => "sha_password_test"},
        "dbserver" => {"ssh_user"=>"ssh_user_test", "ssh_password" => "password_test", "ssh_password_sha" => "sha_password_test"}
    }
end

def valid_data 
    {
        "credentials"=> {:provider => "host_provider"},
        "options" => {"image" => "image_id" , "bootstrap-version" => "11.4.4"},
        "other_options" => {"environment" => "environment", "flavor" => "flavor", "node-name" => "node_name"},
        "web_service" => "host_provider",
        "encrypted_data_bag_location" => "encrypted_data_bag_location",
        "machine" => { "appserver"=> { "roles" => "chef_roles" }, "dbserver" => { "roles" => "chef_roles" } }
    }
end

def valid_provider
    ENV.stub(:[]).with('HOME').and_return("my_home")
    provider =  Provider.new "configuration"
    provider.data = valid_data
    provider.parameters = valid_parameters
    provider.options = valid_options
    provider
end

def valid_rackspace_provider
    ENV.stub(:[]).with('HOME').and_return("my_home")
    ENV.stub(:[]).with('RACKSPACE_API_KEY')
    ENV.stub(:[]).with('RACKSPACE_USERNAME')
    ENV.stub(:[]).with('RACKSPACE_ENCRYPTED_BAG_SECRET_LOCATION')
    provider =  RackspaceProvider.new
    provider.data = valid_data
    provider.parameters = valid_parameters
    provider.options = valid_options
    provider
end