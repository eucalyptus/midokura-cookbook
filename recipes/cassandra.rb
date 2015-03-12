yum_repository "datastax" do
  description "DataStax Repo for Apache Cassandra"
  url "http://rpm.datastax.com/community"
  gpgcheck false
  metadata_expire "1"
  sslverify false
  action :create
end

package 'dsc20'
package 'cassandra20'

execute "Set cassandra listening address" do
 command "sed -i -e 's/localhost/#{node['fqdn']}/g' /etc/cassandra/conf/cassandra.yaml"
 command "sed -i -e 's/Test\ Cluster/#{node['cassandra']['cluster_name']}/g' /etc/cassandra/conf/cassandra.yaml"
end

service "dsc20" do
  action [ :enable, :start ]
  supports :status => true, :start => true, :stop => true, :restart => true
end

service "cassandra20" do
  action [ :enable, :start ]
  supports :status => true, :start => true, :stop => true, :restart => true
end
