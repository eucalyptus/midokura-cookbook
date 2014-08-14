include_recipe "midokura::_common"

package "midonet-api"
package "python-midonetclient"
package "tomcat"

# HACK: the midonet-api package should include tomcat loader midonet-api.xml
file "/etc/tomcat/Catalina/localhost/midonet-api.xml" do
  content "<Context path=\"/midonet-api\" docBase=\"/usr/share/midonet-api\" antiResourceLocking=\"false\" privileged=\"true\"/>"
  owner "tomcat"
  group "tomcat"
  mode 00774
end

# Hack: the midonet-api should not ship with servlet.jar
file "/usr/share/midonet-api/WEB-INF/lib/servlet-api-2.5-20081211.jar" do
  action :delete
end

template "/usr/share/midonet-api/WEB-INF/web.xml" do
  source "web.xml.erb"
  mode 00774
  owner "tomcat"
  group "tomcat"
  notifies :restart, "service[tomcat]"
end

service 'tomcat' do
  action [:enable, :start]
end
