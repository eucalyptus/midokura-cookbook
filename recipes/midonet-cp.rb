include_recipe "midokura::_common"

package "midonet-cp"

template "/var/www/html/midonet-cp/config.js" do
  source "midonet-cp.js.erb"
  owner "apache"
  group "apache"
  notifies :restart, "service[httpd]", :immediately
end

service "httpd" do
  action [:enable, :start]
end
