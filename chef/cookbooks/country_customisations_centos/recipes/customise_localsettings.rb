include_recipe "country_customisations_centos::clone_configuration_repo"

chef_env = node.chef_environment
puts "Chef environment is #{chef_env}"

kannel_credentials = Chef::EncryptedDataBagItem.load("kannel_credentials", chef_env)

ruby_block "Replace MAP_ARGS in localsettings" do
  block do
    require "yaml"
    require "json"
      if node.has_key? ('language')
        language = node['language']
      else
         language = "en"
      end

      map_args = YAML::load(File.open("/home/ureport/code/configuration/map_args.yaml"))
      map_bounds = YAML::load(File.open("/home/ureport/code/configuration/coordinates.yaml"))

      if File.exists? "/home/ureport/code/configuration/country_specific_tokens.yaml"
        country_specific_tokens = YAML::load(File.open("/home/ureport/code/configuration/country_specific_tokens.yaml"))
      else
        country_specific_tokens = {:tokens => nil, :rules => nil, :opt_in_words => nil,:opt_out_words => nil}
      end

      if File.exists? "/home/ureport/code/configuration/encoding_configuration.yaml"
        encoding_configuration = YAML::load(File.open("/home/ureport/code/configuration/encoding_configuration.yaml"))
      else
        encoding_configuration = {:charset => nil, :coding => nil}
      end

      res = Chef::Resource::Template.new("/home/ureport/code/ureport/ureport_project/localsettings.py", node.run_context)
      res.source "localsettings.py.erb"
      res.cookbook "country_customisations"
      res.variables ({
        :username => kannel_credentials['username'],
        :password => kannel_credentials['password'],
        :from => kannel_credentials['from'],
        :bottom_left_lon => map_bounds['bottom_left_lon'],
        :bottom_left_lat => map_bounds['bottom_left_lat'],
        :top_right_lon => map_bounds['top_right_lon'],
        :top_right_lat => map_bounds['top_right_lat'],
        :map_center_longitude => map_args['map_center_longitude'],
        :map_center_latitude => map_args['map_center_latitude'],
        :map_scale => map_args['map_scale'],
        :country_specific_tokens => country_specific_tokens['tokens'],
        :country_rules => country_specific_tokens['rules'],
        :opt_in_words => country_specific_tokens['opt_in_words'],
        :opt_out_words => country_specific_tokens['opt_out_words'],
        :encoding_configuration => encoding_configuration,
        :language => language
      })
      res.run_action(:create)
  end
end
