include_recipe 'java'

execute 'install openssl-devel' do
  command 'yum -y install openssl-devel'
end

include_recipe 'cassandra'
include_recipe 'midokura::zookeeper'
include_recipe 'midokura::midolman'
include_recipe 'midokura::midonet-api'
#include_recipe 'midokura::midonet-cp'
