include_recipe "midokura::_common"

# Kernel shipping with RHEL/CentOS 6.5   has issues with ip_gre module
package "kernel" do
  action :upgrade
end

package "midolman"
execute "echo 'JAVA_HOME=/usr/lib/jvm/java-1.7.0/'| cat - /etc/midolman/midolman-env.sh > /tmp/out && mv /tmp/out /etc/midolman/midolman-env.sh"

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

service 'cassandra' do
  action :start
end

# HACK: the midolman daemon does not support chkconfig
service 'midolman' do
  action :start
end
