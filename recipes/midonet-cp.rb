include_recipe "midokura::default"

package "midonet-cp"

template "/var/www/html/midonet-cp/config.json" do
  source "midonet-cp.json.erb"
  mode 0440
  owner "root"
  group "root"
  notifies :restart, "service[httpd]", :immediately
end

service "httpd" do
  action [:enable, :start]
end
