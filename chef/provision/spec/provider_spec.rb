require 'rspec'

require_relative "../provider.rb"
require_relative "../provider_helper.rb"
require_relative "../helper.rb"


describe Provider do

  let(:provider) { valid_provider }

  describe "#new" do
    let(:provider) { Provider.new "anything" }
    let(:file_content) { "credentials : rackspace" }
    it "should create a new Provider with data given a existent configuration file" do

      File.stub(:read).with("anything.yml").and_return(file_content)
      File.stub(:exists?).with("anything.yml").and_return true

      provider.data.should == {"credentials" => "rackspace"}
    end
    it "should create a new Provider with no data given a non existent configuration file" do

      File.stub(:read).with("anything.yml").and_return(file_content)
      File.stub(:exists?).with("anything.yml").and_return false

      provider.data.should == {}
    end
  end

  describe "ssh_user" do
    it "should return a valid ssh user " do
      provider.get_ssh_user.should == "root"
    end
  end

  describe "ssh_password" do
    it "should return a valid ssh password " do
      provider.get_ssh_password.should == "server@ureport@2014"
    end
  end

  describe "create networking file" do
    let(:appserver_name) { "appserver_name" }
    let(:dbserver_name) { "dbserver_name" }
    let(:backup_dbserver_name) { "backup_dbserver_name" }
    let(:server_name) { "server_name" }
    let(:file_name) { "my_home/tmp/secrets/#{server_name}-network.json" }
    before(:each) do
      provider.stub :execute_in_terminal
    end

    it "should create networking file with server data for appserver and dbserver" do
      content = "{ \"id\" : \"#{server_name}\", \"appserver_node\" : \"#{appserver_name}\", \"dbserver_node\" : \"#{dbserver_name}\" }\n"

      file = mock File
      file.should_receive(:puts).with(content)
      File.should_receive(:open).with(file_name, "a+").and_yield(file)

      provider.create_networking_file server_name, appserver_name, dbserver_name
    end

    it "should create networking file with server data for appserver,db server and backup dbserver" do
      content = "{ \"id\" : \"#{server_name}\", \"appserver_node\" : \"#{appserver_name}\", \"dbserver_node\" : \"#{dbserver_name}\",\"backup_dbserver_node\": \"#{backup_dbserver_name}\" }\n"

      file = mock File
      file.should_receive(:puts).with(content)
      File.should_receive(:open).with(file_name, "a+").and_yield(file)

      provider.create_networking_file server_name, appserver_name, dbserver_name, backup_dbserver_name
    end

    it "should save networking configurationin data bag" do
      save_network_file = "knife data bag from file --secret-file #{provider.data["encrypted_data_bag_location"]} node_networking #{file_name}"

      file = mock File
      file.stub :puts
      File.should_receive(:open).with(file_name, "a+").and_yield(file)

      provider.should_receive(:execute_in_terminal).with save_network_file
      provider.create_networking_file server_name, appserver_name, dbserver_name
    end
  end

  describe "create_password_file" do

    let(:server_name) { "server_name" }
    let(:file_name) { "my_home/tmp/secrets/#{server_name}.json" }
    let(:server_type) { "appserver" }

    before(:each) do
      provider.stub :execute_in_terminal
    end

    it "should create password file for server" do
      content = "{ \"id\" : \"server_name\", \"username\" : \"ssh_user_test\", \"password\" : \"sha_password_test\" }\n"
      file = mock File
      provider.stub :execute_in_terminal
      file.should_receive(:puts).with(content)
      File.should_receive(:open).with(file_name, "a+").and_yield(file)
      provider.create_password_file server_name, server_type
    end

    it "should save password credentials in the data bag" do
      save_password_file = "knife data bag from file --secret-file #{provider.data["encrypted_data_bag_location"]} node_users #{file_name}"
      file = mock File
      file.stub :puts
      provider.stub :execute_in_terminal
      File.should_receive(:open).with(file_name, "a+").and_yield(file)
      provider.should_receive(:execute_in_terminal).with save_password_file
      provider.create_password_file server_name, server_type
    end
  end

  describe "setup ssh users configuration" do
    it "should create a set of parameters with the ssh users and passwords for the different roles" do
      provider.stub(:setup_backup_dbserver)
      provider.stub(:get_ssh_user).and_return("user")
      provider.stub(:get_ssh_password).and_return("password")
      provider.stub(:openssl).with("password").and_return("ssl_password")

      provider.setup_ssh_users_configuration
      provider.parameters["dbserver"]["ssh_user"].should == "user"
      provider.parameters["dbserver"]["ssh_password"].should == "password"
      provider.parameters["dbserver"]["ssh_password_sha"].should == "ssl_password"
      provider.parameters["appserver"]["ssh_user"].should == "user"
      provider.parameters["appserver"]["ssh_password"].should == "password"
      provider.parameters["appserver"]["ssh_password_sha"].should == "ssl_password"
    end
  end

  describe "setup ssh users configuration" do
    before :each do
      provider.stub(:get_user_input).with("Would you like to have a backup server").and_return("y")
      provider.stub(:get_ssh_user).and_return("user")
      provider.stub(:get_ssh_password).and_return("password")
      provider.stub(:openssl).with("password").and_return("ssl_password")
    end
    it "should create a set of parameters with the ssh users and passwords for the different roles with backup db server" do
      provider.setup_backup_dbserver
      provider.parameters["backup_dbserver"]["ssh_user"].should == "user"
      provider.parameters["backup_dbserver"]["ssh_password"].should == "password"
      provider.parameters["backup_dbserver"]["ssh_password_sha"].should == "ssl_password"
    end
    it "should configure node-name for backup_dbserver" do
      provider.stub(:get_node_name_for).with("backup_dbserver").and_return("servername-backup-dbserver")

      provider.setup_backup_dbserver
      provider.options["node-name"][:backup_dbserver].should == "servername-backup-dbserver"
    end
    it "should have pertinent roles" do
      roles = {"roles" => "role[bootstrap],role[backup_db_server]"}

      provider.setup_backup_dbserver
      provider.parameters["backup_dbserver"].should include roles
    end
  end

  describe "openssl" do
    it "should encrypt using openssl from the command line" do
      text = "my_password"
      instruction="openssl passwd -1 #{text}"
      provider.stub(:execute_in_terminal).with(instruction).and_return("encrypted_text\n")
      provider.should_receive(:execute_in_terminal).with(instruction)

      provider.openssl(text).should == "encrypted_text"
    end
  end

  describe "create_server for server type" do
    let(:server_type) { "appserver" }
    let(:options) { " --option1 value1 --option2 value2" }
    before(:each) do
      provider.stub(:create_password_file)
      provider.stub(:create_networking_file)
      provider.stub(:execute_in_terminal)
      provider.stub(:options_for_role).and_return(options)
    end
    it "should create password config for role" do
      provider.should_receive(:create_password_file).with(provider.options["node-name"][server_type.to_sym], server_type)
      provider.create_server_for server_type
    end
    it "should create networking config for role" do
      node_names = provider.options["node-name"]
      node_names[:backup_dbserver] = "servername-backup-dbserver"

      provider.should_receive(:create_networking_file).with(node_names[server_type.to_sym], node_names[:appserver],
                                                            node_names[:dbserver], node_names[:backup_dbserver])

      provider.create_server_for server_type
    end
    it "should create server for role using knife with valid option" do
      instruction = "knife #{provider.data["web_service"]} server create -r #{provider.parameters[server_type]["roles"]} #{options}"
      provider.should_receive(:options_for_role).with server_type.to_sym
      provider.should_receive(:execute_in_terminal).with instruction
      provider.create_server_for server_type
    end
  end

  describe "create temporary directory" do
    it "creates a temporary folder" do
      directory="my_home/tmp/secrets/"
      remove_directory_instruction = "rm -rf #{directory}"
      create_directory_instruction = "mkdir -p #{directory}"
      provider.stub(:execute_in_terminal)
      provider.should_receive(:execute_in_terminal).with remove_directory_instruction
      provider.should_receive(:execute_in_terminal).with create_directory_instruction
      provider.create_temp_folder
    end
  end

  describe "setup create server options" do
    it "should create the right set of server options" do
      provider.stub(:get_user_input).with("Name prefix (e.g. chris-)").and_return("prefix-")
      provider.stub(:select_environment).and_return("dev")
      provider.stub(:select_flavor).and_return("5")
      provider.stub(:setup_ssh_users_configuration)

      provider.setup_create_server_options

      provider.options['environment'].should == "dev"
      provider.options["flavor"].should == "5"
      provider.options["node-name"].should == {:dbserver => "prefix-dev-dbserver", :appserver => "prefix-dev-appserver"}
    end
  end

  describe "create app servers" do
    it "should create the servers for each role" do
      number_of_roles = provider.parameters.keys.count
      provider.stub(:create_server_for)
      provider.stub(:setup_create_server_options)
      provider.stub(:create_temp_folder)

      provider.should_receive :setup_create_server_options
      provider.should_receive :create_temp_folder
      provider.should_receive(:create_server_for).exactly(number_of_roles).times

      provider.create_servers
    end
  end

  describe "configure app servers" do
    before :each do
      provider.stub :configure_networking_for
      provider.stub :configure_database_for
      provider.stub :restart_appserver_services
    end
    it "should configure server network" do
      number_of_roles = 2 #provider.parameters.keys.count

      provider.should_receive(:configure_networking_for).exactly(number_of_roles).times
      provider.configure_servers
    end
    it "should initialize database in appserver" do
      provider.should_receive(:configure_database_for).with "appserver"
      provider.configure_servers
    end
  end

  describe "configure networking for server" do
    it "should call chef client with role networking" do
      provider.stub :query_chef_client
      provider.should_receive(:query_chef_client).with("appserver", 'role[networking]')
      provider.configure_networking_for "appserver"
    end
  end

  describe "configure database for server" do
    it "should call chef client with role for init_db" do
      provider.stub :query_chef_client
      provider.should_receive(:query_chef_client).with("appserver", 'role[init_db],role[customise_application]')
      provider.configure_database_for "appserver"
    end
  end

  describe "query chef client" do
    let(:query) { "role[sample-role]" }
    let(:node_name) { "servername-appserver" }
    let(:server_type) { "appserver" }
    before :each do
      provider.stub :execute_in_terminal
    end
    it "should build the query with knife_ssh_attributes" do
      knife_ssh_attributes = {"ssh-user" => "ssh_user", "attribute" => "ip"}
      provider.data["knife_ssh_attributes"] = knife_ssh_attributes

      instruction = "knife ssh name:#{node_name} --ssh-user ssh_user --attribute ip \"sudo chef-client -o 'role[sample-role]' --once\""

      provider.should_receive(:execute_in_terminal).with instruction
      provider.query_chef_client server_type, query
    end

    it "should call for specific attributes for server_type" do
      provider.stub(:attributes_for).with(server_type).and_return({"attribute" => "test_att", "P" => "password"})
      instruction = "knife ssh name:#{node_name} --attribute test_att --P password \"sudo chef-client -o 'role[sample-role]' --once\""

      provider.should_receive(:execute_in_terminal).with instruction
      provider.query_chef_client server_type, query
    end
  end
end

