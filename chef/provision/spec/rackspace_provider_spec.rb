require 'rspec'

require_relative "../provider.rb"
require_relative "../rackspace_provider.rb"
require_relative "../provider_helper.rb"
require_relative "../helper.rb"


describe RackspaceProvider do

  let(:provider) { valid_rackspace_provider }
  let(:knife_ssh_attributes) { { "ssh-user" => "ssh_user", "attribute" => "ip" } }

  describe "ensure that password for server type gets included" do
    before :each do
      #given
      provider.parameters["appserver"]["ssh_password"] = "testing-password"
      provider.data["knife_ssh_attributes"] = knife_ssh_attributes
    end
    it "should add the server_type password to the ssh attributes" do
      #act
      appserver_attributes = provider.attributes_for "appserver"
      #assert

      appserver_attributes.should include knife_ssh_attributes
      appserver_attributes["ssh-password"].should == "testing-password"
    end
    it "should add the server_type password to the ssh attributes using symbol server type" do
      #act
      appserver_attributes = provider.attributes_for :appserver
      #assert

      appserver_attributes.should include knife_ssh_attributes
      appserver_attributes["ssh-password"].should == "testing-password"
    end
  end

end