package "s3cmd" do
    action :install
end

template "/home/ureport/.s3cfg" do
 source "s3cfg.erb"
end


cookbook_file "backup_db_s3.sh" do
  path "/home/ureport/backup_db_s3.sh"
  action :create
end

execute "make script excecutable" do
	command "chmod +x /home/ureport/backup_db_s3.sh"
	cwd "/home/ureport/"
	action :run
end


cron "backup db" do
    home "/home/ureport"
    command "sudo /home/ureport/backup_db_s3.sh"
    action :create
    hour "1"
    minute "0"
end
