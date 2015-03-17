include_recipe "midokura::_common"

if (node['midokura']['zookeepers'] == [])
  raise "Please set the Midokura zookeepers list attribute in your environment: midokura->zookepers"
end

directory "/usr/java"

link "/usr/java/default" do
  to "/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.75.x86_64/jre/"
  only_if 'test -d /usr/lib/jvm/java-1.7.0-openjdk-1.7.0.75.x86_64/jre'
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
