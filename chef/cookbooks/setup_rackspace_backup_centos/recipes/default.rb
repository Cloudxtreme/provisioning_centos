dumps_directory = "/home/ureport/dumps"
backups_directory = "/home/ureport/backups"
dump_script = "/home/ureport/scripts/create_dump.sh"
backup_scripts_directory = "/home/ureport/scripts/backup"


rackspace_config = Chef::EncryptedDataBagItem.load("rackspace_config", "main")

execute "get the agent" do
    command <<-EOH
    sudo sh -c 'wget -q "http://agentrepo.drivesrvr.com/debian/agentrepo.key" -O- | apt-key add -'
    EOH
    action :run
end

execute "add the resource" do
    command <<-EOH
    sudo sh -c 'echo "deb [arch=amd64] http://agentrepo.drivesrvr.com/debian/ serveragent main" > /etc/apt/sources.list.d/driveclient.list'
    EOH
    action :run
end

#execute "update centos repo" do
#    command "yum check-update"
#    action :run
#end

package "driveclient" do
    action :install
end

execute "configure the bootstrap" do
    command "sudo /usr/local/bin/driveclient --username #{rackspace_config['username']} --apikey #{rackspace_config['password']} --configure"
    action :run
end

service "driveclient" do
    action :start
end

execute "set the Agent to start on boot" do
    command "sudo update-rc.d driveclient defaults"
    action :run
end

directory dumps_directory do
          mode 00777
          action :create
          recursive true
end

directory backups_directory do
          mode 00777
          action :create
          recursive true
end

directory backup_scripts_directory do
          mode 00777
          action :create
          recursive true
end

template dump_script do
          source "create_dump.erb"
          mode 00755
          variables(
                :dump_folder => dumps_directory,
                :dump_file  => "db_ureport.sql",
                :backup_folder => backups_directory
           )
end

cron "create daily database dump" do
          command "bash -c '#{dump_script}' > /var/log/db-backup-cron.log 2>&1"
          minute "0"
          hour "22"
          action :create
end

template "#{backup_scripts_directory}/db_backup.py" do
      source "db_backup.py.erb"
          variables(
                :rackspace_username => rackspace_config['username'],
                :rackspace_api_key => rackspace_config['password']
           )
end

template "#{backup_scripts_directory}/perform_backup.py" do
      source "perform_backup.py.erb"
          variables(
                :rackspace_username => rackspace_config['username'],
                :rackspace_api_key => rackspace_config['password']
           )
end

cookbook_file "#{backup_scripts_directory}/backup.py" do
      source "backup.py"
      action :create
      mode 0550
end

cookbook_file "#{backup_scripts_directory}/rackspace_client.py" do
      source "rackspace_client.py"
      action :create
      mode 0550
end

execute "create python environment for the backup script" do
      cwd backup_scripts_directory
      command "virtualenv --no-site-packages rackspace_env"
      action :run
end

execute "install pip requirements" do
      command "#{backup_scripts_directory}/rackspace_env/bin/pip install keyring pyrax python-novaclient rackspace-novaclient"
      action :run
end

execute "setup daily rackspace backup" do
      machine_name = node.name
      email = "ureport@thoughtworks.com"
      backup_time = "11:00pm"

      command "#{backup_scripts_directory}/rackspace_env/bin/python #{backup_scripts_directory}/db_backup.py #{machine_name} #{email} #{backup_time}"
      action :run
end

