#
# Cookbook Name:: midokura
# Recipe:: nuke
#
# © Copyright 2016 Hewlett Packard Enterprise Development Company LP
##
##Licensed under the Apache License, Version 2.0 (the "License");
##you may not use this file except in compliance with the License.
##You may obtain a copy of the License at
##
##    http://www.apache.org/licenses/LICENSE-2.0
##
##    Unless required by applicable law or agreed to in writing, software
##    distributed under the License is distributed on an "AS IS" BASIS,
##    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##    See the License for the specific language governing permissions and
##    limitations under the License.
##
require 'chef/version_constraint'

# Stop all components

### Stop Zookeeper service
service 'zookeeper' do
  action [ :stop ]
end

### Stop Cassandra service
if Chef::VersionConstraint.new("~> 6.0").include?(node['platform_version'])
  service "cassandra" do
    action [ :stop ]
    only_if "ls /etc/rc.d/init.d/cassandra"
  end
end
if Chef::VersionConstraint.new("~> 7.0").include?(node['platform_version'])
  # stop cassandra service on el7 with service command, the current rpm (2.0.17-1)
  # doesn't have a proper systemd unit file and therefore 'systemctl' fails
  execute "Stop cassandra service with system V init" do
    command "service cassandra stop"
    only_if "ls /etc/rc.d/init.d/cassandra"
  end
end

### Stop Midolman service
service 'midolman' do
  action [ :stop ]
end

### Stop Tomcat service
service 'tomcat' do
  action [ :stop ]
end

## Purge all Packages
removelist = %w{zookeeper #{node['cassandra']['package']} cassandra20 midolman
    midonet-api python-midonetclient tomcat tomcat-servlet tomcat-jsp-2.2-api
    tomcat-el-2.2-api tomcat-lib apache-commons-collections apache-commons-daemon
    apache-commons-dbcp apache-commons-logging apache-commons-pool}

removelist.each do |pkg|
  package pkg do
    action :purge
  end
end

## remove iproute-2.6... package if it was installed
if Chef::VersionConstraint.new("~> 6.0").include?(node['platform_version'])
  package "iproute-2.6.32-130.el6ost.netns.2" do
    action :purge
  end
end

## Delete File system artifacts
if node['zookeeper']['uninstall']['destroy'] == true
  directory node['zookeeper']['libsdir'] do
    recursive true
    action :delete
  end

  directory "/etc/zookeeper" do
    recursive true
    action :delete
  end
end

if node['cassandra']['uninstall']['destroy'] == true
  directory "/etc/cassandra" do
    recursive true
    action :delete
  end
end

if node['midokura']['uninstall']['destroy'] == true
  directory "/etc/midolman" do
    recursive true
    action :delete
  end

  if Chef::VersionConstraint.new("~> 6.0").include?(node['platform_version'])
    # HACK: the midolman daemon does not support chkconfig remove init we added

    file "/etc/init.d/midolman" do
      action :delete
    end
  end

  file "/etc/tomcat/Catalina/localhost/midonet-api.xml" do
    action :delete
  end

  file "/usr/share/midonet-api/WEB-INF/web.xml" do
    action :delete
  end
end

## Remove yum repos

yum_repository "midokura-main" do
  url node["midokura"]["repo-url"]
  gpgcheck node["midokura"]["gpgcheck"]
  action :remove
end

yum_repository "midokura-misc" do
  url node["midokura"]["misc-repo-url"]
  gpgcheck node["midokura"]["gpgcheck"]
  action :remove
end

yum_repository "datastax" do
  description "DataStax Repo for Apache Cassandra"
  url node['cassandra']['repo-url']
  gpgcheck false
  action :remove
end

execute "Clear yum cache" do
  command "yum clean all"
end
