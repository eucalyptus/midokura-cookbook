include_recipe 'java'
include_recipe 'cassandra'
include_recipe 'midokura::zookeeper'
include_recipe 'midokura::midolman'
include_recipe 'midokura::midonet-api'
#include_recipe 'midokura::midonet-cp'
include_recipe 'midokura::create-first-resources'
