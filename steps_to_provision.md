#Steps to provision an environment for a new country

##Steps to create a new country:
* Create configuration repository
 * Add the created repo to BOTH the 'uReport developers' group and the 'Machine users' group on GitHub
* Create a Chef environment (usually named <country_name>-prod)
* Add a data bag item into the kannel_credentials data bag with the same id as the environment created above

##Steps after the environment has been provisioned:
- Create a superuser and set a password (manage.py createsuperuser and changepassword)
- Create a group called "Other uReporters" and add the superuser created in the above step to it
