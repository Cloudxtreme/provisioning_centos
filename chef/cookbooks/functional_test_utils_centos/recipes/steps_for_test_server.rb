package "expect" do
  action :install
end

change_password_command = "/home/ureport/virtualenv/ureport/bin/python manage.py changepassword ureport"
expect_script = "expect -c 'spawn #{change_password_command}; expect \"Password: \"; send \"ureport\\n\"; expect \"Password (again): \"; send \"ureport\\n\"; expect eof;'"

execute "Set superuser's password used by functional tests" do
    cwd "/home/ureport/code/ureport/ureport_project"
    command expect_script 
    action :run
end

