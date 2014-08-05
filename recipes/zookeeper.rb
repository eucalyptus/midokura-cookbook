include_recipe "midokura::default"

package "zookeeper"

template "/etc/zookeeper/zoo.cfg" do
  source "zoo.cfg.erb"
  mode 0440
  owner "zookeeper"
  group "zookeeper"
  notifies :restart, "service[zookeeper]", :immediately
end

service 'zookeeper' do
  action [:enable, :start]
end
