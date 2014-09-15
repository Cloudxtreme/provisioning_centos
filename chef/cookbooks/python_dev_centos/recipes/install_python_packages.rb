#execute "update repo information" do
#	command "yum -y update"
#	action :run
#end

execute "Installing Development Tools " do
	command "yum groupinstall -y 'development tools'"
	action :run
end

execute "Installing Required Libraries " do
	command "yum install -y zlib-devel bzip2-devel openssl-devel xz-libs wget"
	action :run
end

execute "Installing Centos Release SCL " do
	command "yum install -y centos-release-SCL"
	action :run
end

execute "Installing Python " do
	command "yum install -y python27 python27-lib python-devel python-nose python-setuptools gcc gcc-gfortran gcc-c++ blas-devel lapack-devel atlas-devel"
	action :run
end

execute "Installing Required Libraries for Python" do
	command "yum install -y libxml2 libxml2-devel libxslt libxslt-devel postgresql-devel"
	action :run
end

execute 'Update PATH environment variable for Python' do
  command 'echo "export PATH=/opt/rh/python27/root/usr/bin${PATH:+:${PATH}}" >> /root/.bashrc'
  action :run
end

execute 'Update LD_LIBRARY_PATH environment variable for Python' do
  command 'echo "export LD_LIBRARY_PATH=/opt/rh/python27/root/usr/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}" >> /root/.bashrc'
  action :run
end

execute 'Update MANPATH environment variable for Python' do
  command 'echo "export MANPATH=/opt/rh/python27/root/usr/share/man:${MANPATH}" >> /root/.bashrc'
  action :run
end

execute 'Update XDG_DATA_DIRS environment variable for Python' do
  command 'echo "export XDG_DATA_DIRS=/opt/rh/python27/root/usr/share${XDG_DATA_DIRS:+:${XDG_DATA_DIRS}}" >> /root/.bashrc'
  action :run
end

execute 'Update PKG_CONFIG_PATH environment variable for Python' do
  command 'echo "export PKG_CONFIG_PATH=/opt/rh/python27/root/usr/lib64/pkgconfig${PKG_CONFIG_PATH:+:${PKG_CONFIG_PATH}}" >> /root/.bashrc'
  action :run
end

execute 'Source PATH environment variable for Python' do
  command "bash -c 'source /root/.bashrc'"
  action :run
end

execute "Installing Setup Tools for Python" do
	command "wget https://bootstrap.pypa.io/ez_setup.py -O - | python"
	action :run
end

execute "Installing PIP for Python" do
	command "easy_install pip"
	action :run
end

execute "virtualenv" do
	command "pip install virtualenv"
end

