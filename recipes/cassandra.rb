require 'chef/version_constraint'

yum_repository "datastax" do
  description "DataStax Repo for Apache Cassandra"
  url node['cassandra']['repo-url']
  gpgcheck false
  metadata_expire "1"
  sslverify false
  action :create
end

package node['cassandra']['package']

execute "CASSANDRA: set listening address" do
 command "sed -i -e 's/localhost/#{node['fqdn']}/g' /etc/cassandra/conf/cassandra.yaml"
end

execute "CASSANDRA: set cluster_name" do
 command "sed -i -e 's/Test\ Cluster/#{node['cassandra']['cluster_name']}/g' /etc/cassandra/conf/cassandra.yaml"
end

cassandra_host_list = node['midokura']['cassandras'].join(',')
execute "CASSANDRA: set seed list" do
 command "sed -i -e 's/seeds:\ \"127.0.0.1\"/seeds:\ \"#{cassandra_host_list}\"/' /etc/cassandra/conf/cassandra.yaml"
end

if Chef::VersionConstraint.new("~> 6.0").include?(node['platform_version'])
  service "cassandra" do
    action [ :enable, :start ]
    supports :status => true, :start => true, :stop => true, :restart => true
  end
end
if Chef::VersionConstraint.new("~> 7.0").include?(node['platform_version'])
  # start cassandra service on el7 with service command, the current rpm (2.0.17-1)
  # doesn't have a proper systemd unit file and therefore 'systemctl' fails
  execute "Start cassandra service with system V init" do
    command "service cassandra start"
  end
end
