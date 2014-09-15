# uReport - Dev

Contains information and scripts to get a development machine up and running very quickly.

If you prefer to use vagrant to setup your environment follow the guide 
https://github.com/ureport/provisioning/wiki/Setting-up-Vagrant

# Tech Stack

    Python (not 3, 2.7)
    VirtualEnv (Like rvm for ruby, manages versions of Python)
    Django 1.3
    Postgresql 9.1 
    Rackspace
    Chef
    Newrelic

# Developer Machine installation (OS X Mountain Lion)

First install git if you don't already have It, and setup a github account and gravatar image and get access to our team.
if you are using git for the first time, follow these instructions to let you push to the ureport repo https://help.github.com/articles/generating-ssh-keys

Create somewhere to store all the stuff, e.g.

    $ mkdir -p ~/Code/unicef/ureport

First clone this repository so that you can update this doc or the developer-faq with anything you learn!

    $ cd ~/Code/unicef/ureport    
    $ git clone git@github.com:ureport/bootstrap.git


Some prerequisites:
    
    Rackspace account (we have to this set up for you)
    Newrelic account
    Homebrew (https://github.com/mxcl/homebrew/wiki/Installation)
    Python (not 3, 2.7)
    XCode Developer Tools 4.6.1 (from your app store)

Then your pip

    $ sudo easy_install pip
    $ pip install virtualenv

If $ pip install virtualenv fails with the message "Permission Denied", try

    $ sudo pip install virtualenv

Go to some folder where you want to store the code and create a folder called “virtualenv”, e.g.

    $ mkdir -p virtualenv

Go in there and run virtualenv

    $ cd virtualenv
    $ virtualenv --no-site-packages ureport
    
Go back and clone the repos:

    $ cd ..
    $ git clone git@github.com:unicefuganda/ureport.git 
    
    <nimrod: ask us about submodules!!>
    
    $ git clone git@github.com:ureport/provisioning.git
    
    $ git clone git@github.com:ureport/performance.git
    
For each repository:

    $ git submodule init
    
    $ git submodule update

Activate your virtualenv so ureport can run on the python instance in the virtualenv:

    $ source ./virtualenv/ureport/bin/activate
    
Configure your python environment     
    
    $ cd ureport

    $ pip install -r pip-requires.txt
    
You can see if this works by 

    $ pip freeze
    
It should show you all the libraries that are in pip-install.txt

<b>Postgres</b>

Download the <i>postgresapp</i> from http://postgresapp.com/

Start the app. A little elephant should appear in your task bar.

Go to the elephant and make sure the first message in the drop down is <i>Running on Port 5432</i>

If the message is <i>Failed to start on port 5432</i>, it is likely the case that your pre-installed
postgres automatically starts on that port. Make sure the pre installed postgres is not running on
that port and that it does not restart itself when you kill it.

Check if there is a pre-existing installation of psql in <code>/usr/bin/</code> by running
<code>which psql</code>. If it exists, rename it using <code>mv /usr/bin/psql /usr/bin/pqsl-old</code> so it does not 
conflict with Postgresapp's psql. Check that it has been removed by running <code>which pqsl</code>.
Check that there is no psql location reported

Then, add the <i>Postgresapp<i> psql to your path. It is prefered that you do add it to your
<code>~/.bashrc</code>. The full path to the <i>Postgresapp<i> psql is 
<code>Users/Nimrod/Downloads/Postgres\ 2.app/Contents/MacOS/bin/psql</code>. 

Login into psql as yourself by running `psql`

Create the role `postgres` with `CREATE ROLE postgres WITH LOGIN CREATEDB;`

In your terminal, run `psql -U postgres`. This should take you into a postgresql prompt

Then create the ureport DB by running <code>CREATE DATABASE ureport;</code>. A success indicator is that
psql prints <code>CREATE DATABASE</code> after you run the command.

Connect to the <code>ureport</code> database by running <code>\connect ureport;</code> and make sure you get the
message <code>You are now connected to database "postgres" as user "xxx".</code> where xxx is local your username

Open a new terminal window, and navigate to the repo by running <code>/path/to/ureport/original-repo/ureport/</code>.

While in that directory, activate your virtual environment by running 
<code>source /path/to/ureport/virtualenv/ureport/bin/activate</code>. Your prompt should now change to start with 
<code>(ureport)</code>

With your virtual environment activated but while still in the repo, run <code>./manage.py syncdb --noinput</code>.
You should see something like this if it succeeds.
    
    Syncing...
    Creating tables ...
    Creating table django_site
    Creating table auth_permission
                    .
                    .
    Creating table south_migrationhistory
    
    Synced:
     > mptt
     > uni_form
         .
         .
     > south
    
    Not synced (use migrations):
     - ureport
     - django_extensions
            .
            .
     -(use ./manage.py migrate to migrate these)
     
Then run the migrations using the command <code>./manage.py migrate</code>.

Now make sure you have postgress installed and running...

    $ lsof -i:5432
    You should see something like:
    COMMAND    PID USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
    postgres 72677 XXXX    5u  IPv6 0x1e7355b40b608055      0t0  TCP
    localhost:postgresql (LISTEN)
    postgres 72677 XXXX    6u  IPv4 0x1e7355b417851705      0t0  TCP
    localhost:postgresql (LISTEN)
    postgres 72677 XXXX    7u  IPv6 0x1e7355b410d27c75      0t0  TCP
    localhost:postgresql (LISTEN)
    
    
You should also be able to do :

    $ psql postgres
    
And it should give you a db console.

Install Chef Client

# Install chef 

    $ gem install chef

Verify that chef has installed by running
    
    $ chef-client -v

You should see something like this:
    
    Chef: 11.4.4

Check that the following folder stucture is present on your local machine
    
    /opt
       /chef
          /bin
          /embedded
             /bin
             /include
             /lib
             /share
             /ssl


# Set up knife-rackspace 
    
    $ gem install knife-rackspace

In your browser, Go to the Chef Server at http://5.79.20.241:4040/clients and create a client using the "Clients" tab.

Enter a client name (your name), tick the box marking your client as an admin and click create. This will generate a private/public key pair that will be associated with the client you create. Save it as:
        
    ~/.chef/<client_name>.pem 

Add the following to `~/.bash_profile` (or appropriate other file if you're using e.g. zsh).

    # Rackspace credentials
    export RACKSPACE_USERNAME="xxx"
    export RACKSPACE_API_KEY="xxx"
    export NEWRELIC_LICENSE_KEY="xxx"

Substitute the xxx with the rackspace details you obtain from one of the developers.
Run the following command to generate the knife configuration file
    
    $ knife configure --initial

When prompted for chef server url, enter

    'http://5.79.20.241:4000'

Edit `~/.chef/knife.rb` and make the following changes:

    client_key               '~/.chef/<client_name>.pem'

Copy the following 5 knife attributes into `~/.chef/knife.rb`:

    knife[:rackspace_api_username] = "#{ENV['RACKSPACE_USERNAME']}"
    knife[:rackspace_api_key] = "#{ENV['RACKSPACE_API_KEY']}"
    knife[:rackspace_version] = 'v2'
    knife[:rackspace_api_auth_url] = "lon.auth.api.rackspacecloud.com"
    knife[:rackspace_endpoint] = "https://lon.servers.api.rackspacecloud.com/v2"

Add:

    encrypted_data_bag_secret '~/.chef/encrypted_data_bag_secret'

To verify:

    $ knife node list

All devs should know how to and be capable of (i.e. have tools / keys installed) spinning up a new environment.
    
# Local nginx

Install nginx version 1.4.0

To have launchd start nginx at login:
    ln -sfv /usr/local/opt/nginx/*.plist ~/Library/LaunchAgents
Then to load nginx now:
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.nginx.plist

# Installing geoserver locally

## Get tomcat installed

    brew install tomcat
    
Edit the file `/usr/local/Cellar/tomcat/<version/libexec/conf/tomcat-users.xml` and add the following user:

    <role rolename="manager-gui"/>
    <user username="<choose a username>" password="<choose a password>" roles="manager-gui" />

Make a convenient shortcut for stopping and starting its
    
    ln -s /usr/local/Cellar/tomcat/7.0.39/bin/catalina /usr/local/bin/tomcat7
    
    ln -s /usr/local/Cellar/tomcat/7.0.39/libexec/ /usr/local/etc/tomcat7

## Link ogr2gr

This is the program that will import shape files to postgres. It lives wherever your Postgres.app file is

    ln -s /Applications/Postgres.app/Contents/MacOS/bin/ogr2ogr /usr/local/bin/ogr2ogr
    
You will need a few libraries...

    brew install libtiff
    
    
## Download geoserver

    mkdir -p ~/tmp/geoserver/war
    
    cd ~/tmp/geoserver/war
    
    wget -O geoserver-2.2.5.zip http://downloads.sourceforge.net/project/geoserver/GeoServer/2.2.5/geoserver-2.2.5-war.zip?r=http%3A%2F%2Fgeoserver.org%2Fdisplay%2FGEOS%2FGeoServer%2B2.2.5
 
    unzip geoserver-2.2.5.zip

    tomcat7 stop
    
    cp geoserver.war /usr/local/etc/tomcat7/webapps
    
    tomcat7 start

    open http://localhost:8080/geoserver

You can see if its worked by looking in 

    tail -f /usr/local/etc/tomcat7/logs/catalina.out
    
If it doesnt work, try tailing that log and restarting tomcat.

## Install the geoserver data directory

First get the zip files
    
    mkdir -p ~/tmp/geoserver/data
    cd ~/tmp/geoserver/data
    
    wget -O geoserver-data.tgz https://github.com/ureport/provisioning/blob/master/chef/cookbooks/geoserver_app/files/default/geoserver-data.tgz?raw=true
    
    mkdir -p /usr/local/var/lib/geoserver_data
    
    cd /usr/local/var/lib/geoserver_data
    
    tar xfvz ~/tmp/geoserver/data/geoserver-data.tgz 
    
Now we need to add some machine specific config

    sudo ln -s /usr/local/var/lib/geoserver_data /var/lib/geoserver_data

    cd /var/lib/geoserver_data/workspaces/unicef/geoserver
    
    wget -O datastore.xml https://raw.github.com/ureport/provisioning/master/chef/cookbooks/geoserver_app/templates/templates/default/datastore.xml.erb
    
We need to replace some variables

    sed "s/<\%= @db_port \%>/put_db_port_here/" datastore.xml >> datastore.xml.merged
    mv datastore.xml.merged datastore.xml
    
    sed "s/<\%= @db_host \%>/put_db_host/" datastore.xml >> datastore.xml.merged
    mv datastore.xml.merged datastore.xml
    
    sed "s/<\%= @user \%>/put_db_user_name_here/" datastore.xml >> datastore.xml.merged
    mv datastore.xml.merged datastore.xml
    
We now need to create our geoserver data base

    mkdir -p ~/tmp/geoserver/db
    
    cd ~/tmp/geoserver/db
    
    wget -O geoserver-db.tgz https://github.com/ureport/provisioning/raw/master/chef/cookbooks/geoserver_db/files/default/geoserver-db.tgz
    
    tar xfvz geoserver-db.tgz 
    
You now have a script in this folder which should setup a geoserver database from scratch. Be warned, it will overwrite the DB if it exists!

    ./configure-geoserver-db.sh 
    
This script will create a databse as your local user on localhost with the default postgres port. You can pass in these parameters.
    
    
Install the postgis extension. You will need this if your shape files are to be mapped to the correct coorinate systems:

    $ psql geoserver
    geoserver=# create extension postgis.

Check that it created a table called spatial_ref_sys by running
    geoserver=# \dt

Now we need to tell geoserver to pick up this data dir...
    
    cd ~/tmp/geoserver
    
    wget -O web.xml https://raw.github.com/ureport/provisioning/master/chef/cookbooks/geoserver_app/templates/templates/default/web.xml.erb
    
    tomcat7 stop
    
    cp web.xml /usr/local/etc/tomcat7/webapps/geoserver/WEB-INF
        
    tomcat7 start
    
    tail -f /usr/local/etc/tomcat7/logs/catalina.out 

And now you should see everthing start up!

If you go into http://localhost:8080/geoserver you should see that there is a unicef workspace and that some layers are there. Also there should be no errors in the log file.

If you have existing data for polls, you will need to export the poll data...

To get this to work, unfortunately we have to patch django!

    patch -p2 -d ${UREPORT_VIRTUAL_ENV_HOME}/lib/python2.7/site-packages/django < ${UREPORT_HOME}/ureport_project/rapidsms_ureport/12890.Django-1.3.diff
   
It will complain about some files which are actually test files. When it does this, keep pressing <ENTER> and it will ask if you want to skip this patch, just say 'y'.


Now we can do this:

    cd ${UREPORT_HOME}/ureport_project

Ensure your virtualenv is activated

    ./manage.py export_poll_data --settings=xxx_settings
    
Where `xxx_settings` is which ever settings file you want to use.

If you don't have the patch applied, you will see this

    django.db.utils.DatabaseError: missing FROM-clause entry for table "t7"
    LINE 1: SELECT (T7.name) AS "location_name", (locations_point.longit...
                ^

   
    
