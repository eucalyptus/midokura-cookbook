include_recipe 'java'

yum_repository "datastax" do
  description "DataStax Repo for Apache Cassandra"
  url "http://rpm.datastax.com/community"
  gpgcheck false
  metadata_expire "1"
  sslverify false
  action :create
end

package 'dsc20-2.0.12-1'
package 'cassandra20-2.0.12-1'

include_recipe 'midokura::zookeeper'
include_recipe 'midokura::midolman'
include_recipe 'midokura::midonet-api'
#include_recipe 'midokura::midonet-cp'
