if [ -z "${RACKSPACE_USERNAME}" -o -z "${RACKSPACE_API_KEY}" ]; then
    echo -e "\nError: You must set \$RACKSPACE_USERNAME and \$RACKSPACE_API_KEY.'\n"
    echo -e "\nError: This is so that the credentials file used by pyrax can be generated.'\n"
    exit -1
fi

echo "Setting up python rackspace client" 
  pip install keyring 
  pip install pyrax 
  pip install python-novaclient 
  pip install rackspace-novaclient 
  pip install os_virtual_interfacesv2_python_novaclient_ext 

echo "Setting up rackspace api credentials"
eval "echo \"$(<rackspace_cloud_credentials.sample)\"" > ~/.rackspace_cloud_credentials
