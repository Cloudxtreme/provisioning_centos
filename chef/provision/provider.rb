require 'fog'
require 'yaml'
require_relative 'helper.rb'

class Provider
  attr_accessor :data, :options, :parameters, :service


  def initialize config
    @temp_folder = "#{ENV['HOME']}/tmp/secrets/"

    if File.exists? "#{config}.yml"
      @data=YAML.load(ERB.new(File.read("#{config}.yml")).result)
    else
      @data = {}
    end
  end

  def start_process
    if has_valid_config
      @service = Fog::Compute.new(@data['credentials'])
      @options = @data["options"]
      create_servers
      configure_servers
  
      if @options["node-name"][:backup_dbserver]
        configure_database_replication
      end
      configure_security
      check_deployed_app
    end
  end
  
  def configure_security
  
  end
  def check_deployed_app
    app_server_node_name = @options["node-name"][:appserver]
    attribute = @data["knife_search_options"]["attribute"]

    appserver_ip = execute_in_terminal "knife search node name:#{app_server_node_name} -a #{attribute} | awk '/#{attribute}/ {print $2;}'"
    puts execute_in_terminal "scripts/check_deployed_app.sh #{appserver_ip.strip!}"
  end

  def configure_database_replication
    run_command_on_remote_node :dbserver, "psql -c \\\"SELECT pg_start_backup('label', true)\\\" -U postgres -h localhost"
    run_command_on_remote_node :dbserver, "psql -c \\\"SELECT pg_stop_backup()\\\" -U postgres -h localhost"
    query_chef_client :backup_dbserver, "recipe[backup_dbserver_recovery]"
    run_command_on_remote_node :backup_dbserver, "sudo service postgresql stop"
    run_command_on_remote_node :dbserver, "sudo service postgresql stop"
    run_command_on_remote_node :dbserver, "sudo rsync -a /var/lib/postgresql/9.1/main/ root@backup.ureport.org:/var/lib/postgresql/9.1/main/ --exclude postmaster.pid -e \\\"ssh -o StrictHostKeyChecking=no\\\""
    run_command_on_remote_node :backup_dbserver, "sudo service postgresql start"
    run_command_on_remote_node :dbserver, "sudo service postgresql start"
  end

  def has_valid_config
    # TODO complete validation of data with proper keys
    true
  end

  def create_servers
    setup_create_server_options
    create_temp_folder

    @parameters.keys.each do |server_type|
      create_server_for server_type
    end
  end

  def setup_create_server_options
    @prefix = get_user_input "Name prefix (e.g. chris-)"

    data["other_options"].each do |option, method|
      @options[option] = send "select_#{method}"
    end

    setup_ssh_users_configuration
  end

  def setup_ssh_users_configuration
    @parameters = @data["machine"]

    @parameters["appserver"]["ssh_user"] = get_ssh_user
    @parameters["appserver"]["ssh_password"] = get_ssh_password
    @parameters["appserver"]["ssh_password_sha"] = openssl @parameters["appserver"]["ssh_password"]
    @parameters["dbserver"]["ssh_user"] = get_ssh_user
    @parameters["dbserver"]["ssh_password"] = get_ssh_password
    @parameters["dbserver"]["ssh_password_sha"] = openssl @parameters["dbserver"]["ssh_password"]

    setup_backup_dbserver
  end

  def openssl text
    encrypted_text = execute_in_terminal "openssl passwd -1 #{text}"
    encrypted_text.gsub("\n", "")
  end

  def get_ssh_user
    "root"
  end

  def get_ssh_password
    "server@ureport@2014"
  end

  def execute_in_terminal instruction
    out_put = %x[#{instruction}]
    puts out_put
    out_put
  end

  def create_password_file server_name, server_type
    file_name = "#{@temp_folder}#{server_name}.json"
    content = "{ \"id\" : \"#{server_name}\", \"username\" : \"#{@parameters[server_type]["ssh_user"]}\", \"password\" : \"#{@parameters[server_type]["ssh_password_sha"]}\" }\n"

    append_text_to_file file_name, content

    save_password_file = "knife data bag from file --secret-file #{@data["encrypted_data_bag_location"]} node_users #{file_name}"
    execute_in_terminal save_password_file
  end

  def create_networking_file server_name, appserver_name, dbserver_name, backup_dbserver_name = nil
    file_name = "#{@temp_folder}#{server_name}-network.json"

    if backup_dbserver_name.nil?
      content = "{ \"id\" : \"#{server_name}\", \"appserver_node\" : \"#{appserver_name}\", \"dbserver_node\" : \"#{dbserver_name}\" }\n"
    else
      content = "{ \"id\" : \"#{server_name}\", \"appserver_node\" : \"#{appserver_name}\", \"dbserver_node\" : \"#{dbserver_name}\",\"backup_dbserver_node\": \"#{backup_dbserver_name}\" }\n"
    end

    append_text_to_file file_name, content

    save_network_file = "knife data bag from file --secret-file #{@data["encrypted_data_bag_location"]} node_networking #{file_name}"

    execute_in_terminal save_network_file
  end

  def setup_backup_dbserver
    has_backup = get_user_input "Would you like to have a backup server"
    if has_backup == "y"
      @parameters["backup_dbserver"] = {"roles" => "role[bootstrap],role[backup_db_server]"}
      @parameters["backup_dbserver"]["ssh_user"] = get_ssh_user
      @parameters["backup_dbserver"]["ssh_password"] = get_ssh_password
      @parameters["backup_dbserver"]["ssh_password_sha"] = openssl @parameters["backup_dbserver"]["ssh_password"]
      @options["node-name"][:backup_dbserver] = get_node_name_for "backup_dbserver"
    end
  end

  def create_temp_folder
    execute_in_terminal "rm -rf #{@temp_folder}"
    execute_in_terminal "mkdir -p #{@temp_folder}"
  end

  def create_server_for server_type
    node_names = @options["node-name"]

    create_password_file node_names[server_type.to_sym], server_type
    create_networking_file node_names[server_type.to_sym], node_names[:appserver], node_names[:dbserver], node_names[:backup_dbserver]
    options = options_for_role server_type.to_sym

    puts "Creating server for #{server_type}"
    instruction = "knife #{@data["web_service"]} server create -r #{@parameters[server_type]["roles"]} #{options}"
    execute_in_terminal instruction
  end

  def configure_servers
    @parameters.keys.each do |server_type|
      configure_networking_for server_type
    end
    configure_database_for "appserver"
    restart_appserver_services
  end

  def configure_networking_for server_type
    query_chef_client server_type, 'role[networking]'
  end

  def configure_database_for server_type
    query_chef_client server_type, "role[init_db],role[customise_application]"
  end

  def restart_appserver_services
    query_chef_client "appserver", "recipe[tomcat::bounce],recipe[uwsgi::bounce]"
  end

  def attributes_for server_type
    @data['knife_ssh_attributes']
  end

  def query_chef_client server_type, query

    run_command_on_remote_node server_type, "sudo chef-client -o '#{query}' --once"
  end

  def run_command_on_remote_node server_type, command
    node_name = @options['node-name'][server_type.to_sym]
    knife_options = ""
    attributes_for(server_type).each do |attribute, value|
      knife_options += " --#{attribute} #{value}"
    end
    knife_options.strip!
    knife_instruction = "knife ssh name:#{node_name} #{knife_options} \"#{command}\""
    puts knife_instruction
    execute_in_terminal knife_instruction
  end
end