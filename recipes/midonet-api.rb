include_recipe "midokura::_common"

package "midonet-api" do
  options node['midokura']['yum-options']
end
package "python-midonetclient" do
  options node['midokura']['yum-options']
end

package "tomcat" do
  options node['midokura']['yum-options']
end

# HACK: the midonet-api package should include tomcat loader midonet-api.xml
file "/etc/tomcat/Catalina/localhost/midonet-api.xml" do
  content "<Context path=\"/midonet-api\" docBase=\"/usr/share/midonet-api\" antiResourceLocking=\"false\" privileged=\"true\"/>"
  owner "tomcat"
  group "tomcat"
  mode 00774
end

# Hack for tomcat 7: the midonet-api should not ship with servlet.jar
#file "/usr/share/midonet-api/WEB-INF/lib/servlet-api-2.5-20081211.jar" do
#  action :delete
#end

template "/usr/share/midonet-api/WEB-INF/web.xml" do
  source "web.xml.erb"
  mode 00774
  owner "tomcat"
  group "tomcat"
  notifies :restart, "service[tomcat]", :immediately
end

service 'tomcat' do
  action [:enable, :start]
end
