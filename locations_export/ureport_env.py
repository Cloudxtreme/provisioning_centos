import os,sys
from django.core.management import setup_environ

sys.path.insert(0,os.getcwd()) 

import localsettings
 
setup_environ(localsettings)

print "\nInitialised ureport env [" + str(__name__) + "] from  : [" + os.getcwd() + "]"
