require 'rspec'
require_relative "../helper.rb"

describe "options_for_role" do
  it "should create --key value string from knife options" do
    @options = { "option1" => "value1", "option2" => {:server1 => "valS1", :server2 => "valS2"} }
    @parameters =
    knife_options = options_for_role :server1
    knife_options.should == " --option1 value1 --option2 valS1"
  end
end