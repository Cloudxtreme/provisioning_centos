SSH into the appserver with the IP address it was created with.
	
	<code>$ ssh root@xx.xx.xx.xx</code>
where xx.xx.xx.xx is the appserver IP address

Then enter the password that chef printed to the console after the appserver was created.
Note that this password could have been changed from the rackspace interface. Use the new
password set from rackspace if the password was changed.

1. Check that <b>localsettings.py</b> exists and that it has the right contents. 
 
	Check that ROUTER_URL is specified under both <code>DATABASES</code> and <code>geoserver</code> and looks like
	<code>ROUTER_URL':'http://kannel.ureport.org:13013/cgi-bin/sendsms?from=8500&username=argha&password=a&text=%(text)s&to=%(recipient)s&smsc=%(backend)s',</code>

2. Check that pip dependencies have been installed <b>in virtualenv</b>
	
	Navigate to the virtualenv directory by running

	<code>$ cd /path to your ureport HOME directory/virtualenv/</code>

	Then check that all pip packages are installed by running
	<code>$ pip freeze</code>
	This should return a list of packages different from the one that is returned when you run the command with virtualenv deactivated.

	Specifically, Check that celery is installed. Run
	
	<code>pip freeze | grep celery</code>
	You should see something like:
	<code>
		celery==xxx
		django-celery==xxx
	</code> where xxx is the version of celery installed

3. Check that <b>bearerbox</b> is running on port 14000 by running:
	<code>$ lsof -i:14000</code>
	This should display an instance of bearerbox and smsbox running on port 14000

4. Check that <b>bearerbox</b> and <b>smsbox</b> are running on port 13000 by running:
	<code>$ lsof -i:13000</code>
	This should display an instance of bearerbox.

5. Check that uwsgi is running
	<code>$ lsof -i:8001</code>
	This should display an instance of uwsig running on port 8001

6. Check that <b>rabbitmq</b> is runnig
	<code>$ lsof -i:5672</code>
	This should display an instance of rabbitmq running on port 5672

7. Check that <b>nginx</b> is running
	<code>$ service nginx status</code>
	You should see
	<code>* nginx is running</code>

8. Check that <b>newrelic</b> is running
	<code>service newrelic-sysmond status</code>
	You should see
	<code>New Relic Server Monitor: newrelic-sysmond is running</code>

9. Check that <b>tomcat</b> is running on 8080
	<code>lsof -i:8080</code>
	You should see an instance of tomcat running on port 8080

10. Check that <b>geoserver_app</b> is running on the same port as specified in the <b>geoserver</b> recipe, in <b>default.rb</b>
	In your browser, go to "<appserver ip address>:8080/geoserver". 
	The geoserver page should load if geoserver is running

11. Use the IP address of the server as displayed on Rackspace to load the home page in the browser.
    Ensure the home page loads

<code> Add more checks here to ensure that blahblah </code>
