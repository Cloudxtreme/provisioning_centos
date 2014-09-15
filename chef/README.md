# The chef provisioning environment

## Useful chef knife commands

### Prerequisites

If you don't already have bundler:

    gem install bundler

In the root of the repository:

    bundle install

### Create a new cookbook

    cd provisioning/chef
    
    knife cookbook create -o cookbooks/ COOKBOOK_NAME

### Write a spec(TEST) for the cookbook, before you actually start writing the cookbook.

	cd provisioning/chef

	knife cookbook create_specs -o cookbooks/ COOKBOOK_NAME

	open COOKBOOK_NAME/spec.default_spec.rb

	Describe your test. Write assertions.

	Run the test using :

	rspec COOKBOOK_NAME

	See tests FAIL.

	Write the cookbook.

	Edit cookbook till all Tests PASS.

### Upload a cookbook to the chef server

    cd cookbooks
    knife cookbook upload -o . COOKBOOK_NAME

### Run a particular role on a server

    chef-client -o 'role[init_db]' --once
    
### Kill a rackspace server

FInd the server id with

    knife rackspace server list
    
the id is the long UUID

    knife rackspace server delete <SERVER-ID> --purge
    
