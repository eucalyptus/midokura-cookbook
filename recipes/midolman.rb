include_recipe "midokura::_common"
require 'chef/version_constraint'

# Kernel shipping with RHEL/CentOS 6.5   has issues with ip_gre module
package "kernel" do
  action :upgrade
  options node['midokura']['yum-options']
end

ip_route_rpm = "#{Chef::Config[:file_cache_path]}/iproute-2.6.32-130.el6ost.netns.2.x86_64.rpm"
remote_file ip_route_rpm do
  source "https://repos.fedorapeople.org/repos/openstack/EOL/openstack-icehouse/epel-6/iproute-2.6.32-130.el6ost.netns.2.x86_64.rpm"
end

package "iproute" do
  source ip_route_rpm
  options node['midokura']['yum-options']
end

package "midolman" do
  options node['midokura']['yum-options']
end

if Chef::VersionConstraint.new("~> 6.0").include?(node['platform_version'])
  package "kmod-openvswitch" do
    options node['midokura']['yum-options']
  end
end


if (node['midokura']['zookeepers'] == [])
  raise "Please set the Midokura zookeepers host list attribute in your environment: midokura->zookeepers"
else
  zookeeper_host_list = node['midokura']['zookeepers'].join(',')
  execute "Set zookeepers in midolman.conf" do
    command "sed -i 's/^zookeeper_hosts.*/zookeeper_hosts = #{zookeeper_host_list}/g' /etc/midolman/midolman.conf"
  end
end

if (node['midokura']['cassandras'] == [])
  raise "Please set the Midokura cassandras host list attribute in your environment: midokura->cassandras"
else
  cassandra_host_list = node['midokura']['cassandras'].join(',')
  execute "Set cassandra nodes in midolman.conf" do
    command "sed -i 's/^servers.*/servers = #{cassandra_host_list}/g' /etc/midolman/midolman.conf"
  end
end

if Chef::VersionConstraint.new("~> 6.0").include?(node['platform_version'])

  # HACK: the midolman daemon does not support chkconfig nor does it properly report status
  # because the el6 packaged init script is broken, continue to use our template for el6, but not for el7
  template "/etc/init.d/midolman" do
    source "midolman.init.erb"
    mode "0655"
  end
end

service 'midolman' do
  action [:start, :enable]
end
