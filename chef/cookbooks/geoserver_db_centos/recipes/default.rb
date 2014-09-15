geoserver_db_directory = "/home/ureport/geoserver-db"

package "gdal-bin" do
  action :install
end

directory "#{geoserver_db_directory}/logs" do
  action :create
  recursive true
end

cookbook_file "create-ureport-geoserver-tables.sql" do
  path "#{geoserver_db_directory}/create-ureport-geoserver-tables.sql"
  action :create
end

cookbook_file "grant-ureport-permissions.sql" do
  path "#{geoserver_db_directory}/grant-ureport-permissions.sql"
  action :create
end

include_recipe "country_customisations_centos::clone_configuration_repo"

ruby_block "Generate the configure shell script pointing to the right shapefile" do
  block do
    require "yaml"
    geoserver_args = YAML::load(File.open("/home/ureport/code/configuration/geoserver_args.yaml"))

    res = Chef::Resource::Template.new("#{geoserver_db_directory}/configure-geoserver-db.sh", node.run_context)
        res.source "configure-geoserver-db.sh.erb"
        res.cookbook "geoserver_db"
        res.mode 0744
        res.variables ({
          :shape_file_path => "/home/ureport/code/configuration/shapefiles/" + geoserver_args['shape_file_name'],
        })
        res.run_action(:create)
  end
end

execute "Change geoserver-db dir owner to postgres" do
  command "chown -R postgres:postgres #{geoserver_db_directory}"
  action :run
end

execute "Setup db" do
  command "sudo -u postgres -H sh -c \"cd #{geoserver_db_directory} && ./configure-geoserver-db.sh > logs/configure-geoserver-db.log 2>&1\""
end
