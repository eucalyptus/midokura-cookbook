include_recipe "midokura::_common"

if (node['midokura']['zookeepers'] == [])
  raise "Please set the Midokura zookeepers list attribute in your environment: midokura->zookepers"
end

package "zookeeper" do
  options node['midokura']['yum-options']
end

template "/etc/zookeeper/zoo.cfg" do
  source "zoo.cfg.erb"
  owner "zookeeper"
  group "zookeeper"
  notifies :restart, "service[zookeeper]", :immediately
end

service 'zookeeper' do
  action [:enable, :start]
end
