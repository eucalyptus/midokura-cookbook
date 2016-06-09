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

package "midolman" do
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

template "/usr/share/midonet-api/WEB-INF/classes/logback.xml" do
  source "logback.xml.erb"
  mode 00774
  owner "tomcat"
  group "tomcat"
end

tomcat_config = "/etc/tomcat/tomcat.conf"
memory = node['tomcat']['jvm']['memory']
tomcat_server_xml = "/etc/tomcat/server.xml"
tomcat_logging_prop = "/etc/tomcat/logging.properties"

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

    Chef::Log.info "updating server.xml to use \"Connector address=127.0.0.1 port=8080\""
    fe2.search_file_replace(/\<Connector port=\"8080\" protocol=\"HTTP\/1.1\"/,
      "\<Connector address=\"127.0.0.1\" port=\"8080\" protocol=\"HTTP\/1.1\"")
    fe2.write_file

    Chef::Log.info "updating logging.properties to remove ConsoleHandler"
    fe3 = Chef::Util::FileEdit.new(tomcat_logging_prop)
    fe3.search_file_replace(/.handlers = 1catalina.org.apache.juli.FileHandler\, java.util.logging.ConsoleHandler/,
      ".handlers = 1catalina.org.apache.juli.FileHandler")
    fe3.search_file_replace(/1catalina.org.apache.juli.FileHandler.level = FINE/,
      "1catalina.org.apache.juli.FileHandler.level = WARN")
    fe3.write_file

  end
  notifies :restart, "service[tomcat]", :immediately
end

service 'tomcat' do
  action [:enable, :start]
end

### Sets Cassandra server config in Zookeeper
#### This overwrites the existing entries with whatever is in the cassandras attr
cassandra_host_list = node['midokura']['cassandras'].join(',')
Chef::Log.info("Setting Cassandra Servers: #{cassandra_host_list}")
bash "Configure Cassandra Servers" do
   code <<-EOH
   echo "Setting Cassandra Servers: #{cassandra_host_list}"
   echo 'cassandra.servers : "#{cassandra_host_list}"' | mn-conf set -t default
   EOH
   retries 6
   retry_delay 10
   flags '-xe'
end
