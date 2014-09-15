require 'io/console'

def get_input_without_echo prompt
	print "#{prompt}: "
	STDIN.noecho(&:gets).chomp
end

def get_user_input prompt
  print "#{prompt}: "
  gets.chomp
end

#TODO: Change to be generic -> backup-dbserver instead of backup_dbserver
def get_node_name_for server_type
    "#{@prefix}#{@options['environment']}-backup-dbserver"
end

def select_node_name
    base = "#{@prefix}#{@options['environment']}"
    {:dbserver => "#{base}-dbserver", :appserver => "#{base}-appserver"}
end

def select_server_name
	@options["node-name"]
end

def select_environment
	get_user_input "\nEnvironment (e.g. dev, south-sudan-prod, ci etc)"
end

def select_flavor
    flavors = @service.flavors
    flavors.each_with_index {|flavor, index| puts "#{flavor.name}: #{index}"}
    flavor_index = get_user_input "\nOption selected"
    flavors[flavor_index.to_i].id
end

def select_security_group
    {:dbserver => "dbserver", :appserver => "appserver", :backup_dbserver => "dbserver"}
end

def select_ebs_size
    {:dbserver => "120", :appserver => "40", :backup_dbserver => "120"}
end

def select_ssh_rackspace_user
    "root"
end

def select_ssh_rackspace_password role
	get_input_without_echo "\n Enter #{role} root Password: "
end

def select_ssh_ec2_user
    "ubuntu"
end

def select_ssh_ec2_password role
    ""
end

def append_text_to_file file_name, text
    File.open(file_name, 'a+') do |file|  
	    file.puts text
    end
end

def options_for_role role
	knife_options = ""
	@options.each do |key, value| 
		if value.is_a? Hash
			knife_options+= " --#{key} #{value[role]}"
		else
			knife_options+= " --#{key} #{value}"
		end
	end
	knife_options
end