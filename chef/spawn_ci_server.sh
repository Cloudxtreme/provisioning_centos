#!/bin/bash

echo "Provisionining a CI server"



#Command to see the list of supported instance sizes on Rackspace
# knife rackspace flavor list

#ID  Name                     VCPUs  RAM    Disk   
#2   512MB Standard Instance  1      512    20 GB  
#3   1GB Standard Instance    1      1024   40 GB  
#4   2GB Standard Instance    2      2048   80 GB  
#5   4GB Standard Instance    2      4096   160 GB 
#6   8GB Standard Instance    4      8192   320 GB 
#7   15GB Standard Instance   6      15360  620 GB 
#8   30GB Standard Instance   8      30720  1200 GB


knife rackspace server create -r 'role[bootstrap],role[ci_server]' --flavor 4 --image 5cebb13a-f783-4f8c-8058-c4182c724ccd --server-name ciserver --node-name ciserver
