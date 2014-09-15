try:
    from os_virtual_interfacesv2_python_novaclient_ext import *
    import pyrax
except:
    print "Error: requires Rackspace libraries to be installed."
    print "Run setup_rackspace_api_client.sh"
    exit()

import os
import sys


if len(sys.argv) < 3:
  print "Usage: ./%s server-name command" % __file__
  exit()

server_name = sys.argv[1]
command = sys.argv[2]

creds_file = os.path.expanduser("~/.rackspace_cloud_credentials")

pyrax.set_setting("region", "LON")
pyrax.set_setting("identity_type", "rackspace")
pyrax.set_credential_file(creds_file)

cs = pyrax.cloudservers
server = cs.servers.find(name=server_name)
interface_manager = VirtualInterfaceManager(cs)

if command == "delete":

  interfaces = interface_manager.list(server.id)
  interface_id_map = dict((interface.ip_addresses[0].get('network_label'),interface.id) for interface in interfaces)

  print "Deleting %s interface %s from server %s " % ('public',interface_id_map.get('public'),server_name)

  interface_manager.delete(server.id, interface_id_map.get('public'))

  print "Interface has been deleted"

elif command == "create":
  print "Adding %s interface to server %s " % ('public', server_name)

  cn = pyrax.cloud_networks
  public_network = cn.find_network_by_label('public')

  interface_manager.create(public_network.id, server.id)

  print "Interface has been created"
