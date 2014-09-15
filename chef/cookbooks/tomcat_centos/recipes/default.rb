tomcat = Chef::EncryptedDataBagItem.load("tomcat", "credentials")


package "tomcat7" do
  action :install
end

package "tomcat7-admin" do
  action :install
end

template "/var/lib/tomcat7/conf/tomcat-users.xml" do
  source "tomcat-users.xml.erb"
  variables({
    :user => tomcat['user'],
    :password => tomcat['password'] 
  })
end

execute "set-permissions" do
  command "chown tomcat7:tomcat7 /var/lib/tomcat7/conf/tomcat-users.xml"
  action :run
end

cookbook_file "/usr/share/tomcat7/bin/setenv.sh" do
	action :create
	mode "0755" 
end
service "tomcat7" do
  action :restart
end
