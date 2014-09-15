#Provisioning scripts

* Provision new environment

	From provisioning/chef

		./provision_new_env.sh
		
* Update rackspace config databag


		./upload_rackspace_config_databag.sh


* Take Database snapshot
		
	 Apply the take_database_snapshot recipe to the database backup server in question with the command :	
 		
 		chef-client -o "recipe[python_dev],recipe[take_database_snapshot]" --once 
 	
 	
* Remove public interface from a database server
 		
 	From your workstation which should be properly configured to access the rackspace client run from inside the provisioning/chef directory :
 
 		./remove_public_interface.sh < DB_server_node_name > < Y/N > [backup_DB_node_name]
 		
* Delete a provisioned server and its chef client
 	
 	From within provisioning/chef
 		
 		./kill_server <instance_id>
