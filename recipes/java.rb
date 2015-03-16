package node['java']['pacakge']

execute "JAVA: set JAVA_HOME" do
 command "export JAVA_HOME=#{node['java']['jdk_location']}"
end

execute "JAVA: set JAVA_HOME" do
 command "echo 'export $JAVA_HOME' >> /root/.bashrc"
end
