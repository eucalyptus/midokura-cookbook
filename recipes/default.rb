include_recipe 'java'

package 'openssl-devel' do
  action :install
end

include_recipe 'cassandra'
include_recipe 'midokura::zookeeper'
include_recipe 'midokura::midolman'
include_recipe 'midokura::midonet-api'
#include_recipe 'midokura::midonet-cp'
