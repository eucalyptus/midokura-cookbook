include_recipe "midokura::default"

package "midonet-api"
package "tomcat6"

template "/usr/share/midonet-api/WEB-INF/web.xml" do
  source "web.xml.erb"
  mode 0440
  owner "root"
  group "root"
  notifies :restart, "service[tomcat6]"
end

service 'tomcat6' do
  action [:enable, :start]
end
