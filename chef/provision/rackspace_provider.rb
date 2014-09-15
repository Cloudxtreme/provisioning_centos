require_relative 'provider'

class RackspaceProvider < Provider

  def initialize  
    super "rackspace"
  end

  def attributes_for server_type
    data["knife_ssh_attributes"]["ssh-password"] = parameters[server_type.to_s]["ssh_password"]
    data["knife_ssh_attributes"]
  end  
  def configure_security
    @options["node-name"].each do |key,nodename| 
      query_chef_client key, "role[security]"
    end   
  end

end
