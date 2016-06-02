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
end

tomcat_config = "/etc/tomcat/tomcat.conf"
memory = node['tomcat']['jvm']['memory']
tomcat_server_xml = "/etc/tomcat/server.xml"

ruby_block "update tomcat.conf and server.xml" do
  block do
    Chef::Log.info "updating tomcat.conf to set JVM heap to \"-Xmx#{node['tomcat']['jvm']['memory']}\""
    fe = Chef::Util::FileEdit.new(tomcat_config)
    fe.insert_line_if_no_match(/^JAVA_OPTS.*/, "JAVA_OPTS=\"-Xmx#{memory}\"")
    fe.write_file
    Chef::Log.info "updating server.xml to comment out \"Connector port=8009\" if found"
    fe2 = Chef::Util::FileEdit.new(tomcat_server_xml)
    fe2.search_file_replace(/\<Connector port=\"8009\" protocol=\"AJP\/1.3\" redirectPort=\"8443\" \/\>/,
      "\<!-- Connector port=\"8009\" protocol=\"AJP\/1.3\" redirectPort=\"8443\" --\>")
    fe2.write_file
  end
  notifies :restart, "service[tomcat]", :immediately
end

service 'tomcat' do
  action [:enable, :start]
end
