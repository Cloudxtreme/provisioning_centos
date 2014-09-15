package "unzip" do
  	action :install
end

execute "Download geoserver" do
	command "wget -O /root/geoserver-2.2.5.zip http://downloads.sourceforge.net/project/geoserver/GeoServer/2.2.5/geoserver-2.2.5-war.zip?r=http%3A%2F%2Fgeoserver.org%2Fdisplay%2FGEOS%2FGeoServer%2B2.2.5"
	action :run
end

execute "Unzip geoserver" do
	command "unzip -o /root/geoserver-2.2.5.zip -d /root"
	action :run
end

service "tomcat7" do
  action :stop
end

template "/etc/init.d/tomcat7" do
  source "tomcat7.erb"
end

execute "Deploy geoserver" do
 	command "unzip -o /root/geoserver.war -d /var/lib/tomcat7/webapps/geoserver"
 	action :run
end

template "/var/lib/tomcat7/webapps/geoserver/WEB-INF/web.xml" do
  source "web.xml.erb"
end

directory "/var/lib/tomcat7/webapps/geoserver/data" do
  action :delete
  recursive true
end

### Install the data

cookbook_file "geoserver-data.tgz" do
  path "/root/geoserver-data.tgz"
  action :create
end

directory "/var/lib/geoserver_data" do
  action :create
  not_if {File.directory? ('/var/lib/geoserver_data')}
end

execute "Untar data" do
  command "tar xvzf /root/geoserver-data.tgz -C /var/lib/geoserver_data"
  action :run
end

template "/var/lib/geoserver_data/workspaces/unicef/geoserver/datastore.xml" do
  source "datastore.xml.erb"
  variables({
    :user => "postgres",
    :db_host => "db.ureport.org",
    :db_port => "5432"
  })
end

include_recipe "country_customisations_centos::clone_configuration_repo"

ruby_block "Configure GeoServer layers 'polls' and 'pollcategories' to reference the proper location name column" do
  block do
    require "yaml"
    geoserver_args = YAML::load(File.open("/home/ureport/code/configuration/geoserver_args.yaml"))

    res = Chef::Resource::Template.new("/var/lib/geoserver_data/workspaces/unicef/geoserver/polls/featuretype.xml", node.run_context)
        res.source "polls_featuretype.xml.erb"
        res.cookbook "geoserver_app"
        res.mode 0744
        res.variables ({
          :location_column_name => geoserver_args['location_column_name'],
        })
        res.run_action(:create)

    res = Chef::Resource::Template.new("/var/lib/geoserver_data/workspaces/unicef/geoserver/pollcategories/featuretype.xml", node.run_context)
        res.source "pollcategories_featuretype.xml.erb"
        res.cookbook "geoserver_app"
        res.mode 0744
        res.variables ({
          :location_column_name => geoserver_args['location_column_name'],
        })
        res.run_action(:create)
  end
end

execute "Set permissions" do
  command "chown tomcat7:tomcat7 -R /var/lib/geoserver_data"
  action :run
end

service "tomcat7" do
  action :restart
end
