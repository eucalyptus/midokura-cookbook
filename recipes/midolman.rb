include_recipe "midokura::_common"

# Kernel shipping with RHEL/CentOS 6.5   has issues with ip_gre module
package "kernel" do
  action :upgrade
end

ip_route_rpm = "#{Chef::Config[:file_cache_path]}/iproute-2.6.32-130.el6ost.netns.2.x86_64.rpm"
remote_file ip_route_rpm do
  source "https://repos.fedorapeople.org/repos/openstack/openstack-icehouse/epel-6/iproute-2.6.32-130.el6ost.netns.2.x86_64.rpm"
end

package "iproute" do
  source ip_route_rpm
end

package "midolman"

package "kmod-openvswitch"

if node['midokura']['zookeepers']
  zookeeper_host_list = node['midokura']['zookeepers'].join(',')
  execute "Set zookeepers in midolman.conf" do
    command "sed -i 's/^zookeeper_hosts.*/zookeeper_hosts = #{zookeeper_host_list}/g' /etc/midolman/midolman.conf"
  end
end

if node['midokura']['cassandras']
  cassandra_host_list = node['midokura']['cassandras'].join(',')
  execute "Set cassandra nodes in midolman.conf" do
    command "sed -i 's/^servers.*/servers = #{cassandra_host_list}/g' /etc/midolman/midolman.conf"
  end
end

# HACK: the midolman daemon does not support chkconfig nor does it properly report status
template "/etc/init.d/midolman" do
  source "midolman.init.erb"
  mode "0655"
end

service 'midolman' do
  action [:start, :enable]
end
