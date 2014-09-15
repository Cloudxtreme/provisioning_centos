name              "java_centos"
maintainer        "Opscode, Inc."
maintainer_email  "cookbooks@opscode.com"
license           "Apache 2.0"
description       "Installs Java runtime."
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "1.9.4"

recipe "java_centos", "Installs Java runtime"
recipe "java_centos::openjdk", "Installs the OpenJDK flavor of Java"
recipe "java_centos::oracle", "Installs the Oracle flavor of Java"
recipe "java_centos::oracle_i386", "Installs the 32-bit jvm without setting it as the default"


%w{ debian ubuntu centos redhat scientific fedora amazon arch freebsd windows }.each do |os|
  supports os
end

