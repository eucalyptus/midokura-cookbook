require 'chef/version_constraint'
include_recipe "midokura::_common"

if (node['midokura']['zookeepers'] == [])
  raise "Please set the Midokura zookeepers list attribute in your environment: midokura->zookepers"
end

### Install Zookeeper
package "zookeeper" do
  options node['midokura']['yum-options']
end

### Build the Zookeeper environment config from provided attributes
template "/etc/zookeeper/zookeeper-env.sh" do
  source "zookeeper-env.sh.erb"
  owner "zookeeper"
  group "zookeeper"
  if Chef::VersionConstraint.new("~> 6.0").include?(node['platform_version'])
    notifies :restart, "service[zookeeper]", :delayed
  end
  if Chef::VersionConstraint.new("~> 7.0").include?(node['platform_version'])
    notifies :run, 'execute[Start zookeeper service with system V init]', :delayed
  end
end


### Build the Zookeeper config from provided attributes
template "/etc/zookeeper/zoo.cfg" do
  source "zoo.cfg.erb"
  owner "zookeeper"
  group "zookeeper"
  if Chef::VersionConstraint.new("~> 6.0").include?(node['platform_version'])
    notifies :restart, "service[zookeeper]", :delayed
  end
  if Chef::VersionConstraint.new("~> 7.0").include?(node['platform_version'])
    notifies :run, 'execute[Start zookeeper service with system V init]', :delayed
  end
end

### Create or maintain zk libs dir and perms
directory node["zookeeper"]["libsdir"] do
  owner 'zookeeper'
  group 'zookeeper'
  recursive true
  mode '0770'
  action :create
end

### Create or maintain zk data dir and perms 
datadir = "#{node["zookeeper"]["libsdir"]}/data"
directory datadir  do
  owner 'zookeeper'
  group 'zookeeper'
  recursive true
  mode '0770'
  action :create
end


### Find the server index for an IP which matches his server
### This will likely limit the host to a single zk instance for now
ruby_block "ZOOKEEPER: create myid" do
    block do
        out = `cat /etc/zookeeper/zoo.cfg | grep server`
        re_server = /(^server\.)([0-9]+)\s*=\s*(([0-9]{1,3}\.){3}([0-9]{1,3}))/
        ip_out = `ip addr show`
        servers = out.scan(re_server)
        servers.each do |val, index, ip|
            Chef::Log.debug("#{index} => #{ip}")
            if ip_out.match(ip)
                Chef::Log.info("Found our local server #{ip} at index #{index}")
		        node.default['zookeeper']['server-index'] = index
                break
            end
        end
	if node['zookeeper']['server-index'].nil? || node['zookeeper']['server-index'].empty?
            raise "Server index not found in zookeeper config?"
	end
    end
end

template "#{datadir}/myid" do
  source "myid.erb"
  mode '0770'
  owner "zookeeper"
  group "zookeeper"
  if Chef::VersionConstraint.new("~> 6.0").include?(node['platform_version'])
    notifies :restart, "service[zookeeper]", :delayed
  end
  if Chef::VersionConstraint.new("~> 7.0").include?(node['platform_version'])
    notifies :run, 'execute[Start zookeeper service with system V init]', :delayed
  end
end

if Chef::VersionConstraint.new("~> 6.0").include?(node['platform_version'])
  ### Start Zookeeper service
  service 'zookeeper' do
    supports :status => true
    supports :restart => true
    action [:enable, :start]
  end
end
if Chef::VersionConstraint.new("~> 7.0").include?(node['platform_version'])
  # start zookeeper service on el7 with service command, the current rpm (3.4.5-1)
  # doesn't have a proper systemd unit file and therefore 'systemctl' fails
  execute "Start zookeeper service with system V init" do
    command "service zookeeper start"
  end
end

### Wait for the zookeeper service to respond as "ok"
ruby_block "ZOOKEEPER: wait for service" do
    block do
        attempts = 5
        ok = false
        for i in 0..attempts
                out = `exec 3<>/dev/tcp/localhost/2181; echo -e ruok >&3; cat <&3`
            if out.match('imok')
                ok = true
                Chef::Log.debug("Zookeeper service is up, ruok response:\"#{out}\"")
                break
            else
                Chef::Log.debug("Zookeeper service was not ok: retry:#{i} of #{attempts}")
                sleep(5*i)
            end
        end
        if not ok
            self.notifies :restart, resources(:service => :"zookeeper"), :immediately
            raise "Zookeeper service was not ok after polling #{i} times"
        end
    end
    retries 3
    retry_delay 10
    action :nothing
end
