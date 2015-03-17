include_recipe "midokura::_common"

if (node['midokura']['zookeepers'] == [])
  raise "Please set the Midokura zookeepers list attribute in your environment: midokura->zookepers"
end

execute "ZOOKEEPER: sym link step 1 create dir" do
 command "mkdir /usr/java"
end

execute "ZOOKEEPER: sym link step 2 create link" do
 command "ln -s /usr/lib/jvm/java-1.7.0-openjdk-1.7.0.75.x86_64/jre/ /usr/java/default"
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
