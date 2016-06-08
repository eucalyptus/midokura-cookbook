require 'chef/version_constraint'

midonet_url = node['midokura']['midonet-api-url']
tunnel_zone_name = node['midokura']['default-tunnel-zone']
initial_tenant = node['midokura']['initial-tenant']
bgp_peers = node['midokura']['bgp-peers']

midonet_command_prefix = "midonet-cli --midonet-url=#{midonet_url} -A"

Chef::Log.info("Checking/Waiting for Midonet API to become available")

### Restart Tomcat and Midolman if the midonet API is not available
if Chef::VersionConstraint.new("~> 6.0").include?(node['platform_version'])
  execute 'Restart Tomcat and Midolman' do
    command "service midolman restart; service tomcat restart"
    retries 3
    retry_delay 10
    not_if "#{midonet_command_prefix} -e help || sleep 20 && #{midonet_command_prefix} -e help"
  end
end
if Chef::VersionConstraint.new("~> 7.0").include?(node['platform_version'])
  execute 'Restart Tomcat and Midolman' do
    command "systemctl restart midolman; systemctl restart tomcat"
    retries 3
    retry_delay 10
    not_if "#{midonet_command_prefix} -e help || sleep 20 && #{midonet_command_prefix} -e help"
  end
end

execute 'Create TunnelZone' do
  command "#{midonet_command_prefix} -e add tunnel-zone name #{tunnel_zone_name} type gre"
  retries 20
  retry_delay 10
  not_if "#{midonet_command_prefix} -e list tunnel-zone | grep #{tunnel_zone_name}"
end

### Add hosts to tunnel zone
members=`#{midonet_command_prefix} -e list tunnel-zone name #{tunnel_zone_name} member`
midolmen = node['midokura']['midolman-host-mapping']
log "Attaching Midolmen: #{midolmen}"
midolmen.each do |hostname, host_ip|
  bash "Configure host: #{hostname}" do
    code <<-EOH
    TZID=`#{midonet_command_prefix} -e list tunnel-zone | grep $TZONE_NAME | awk '{print $2}'`
    HOSTID=` #{midonet_command_prefix} -e host list | grep $HOSTNAME | awk '{print $2}'`
    #{midonet_command_prefix} -e tunnel-zone $TZID add member host $HOSTID address $HOST_IP
    EOH
    environment  'TZONE_NAME' => tunnel_zone_name, 'HOSTNAME' => hostname, 'HOST_IP' => host_ip
    flags '-xe'
    retries 10
    retry_delay 20
    #not_if "#{midonet_command_prefix} -e list tunnel-zone name #{tunnel_zone_name} member | grep #{host_ip}"
    not_if "echo \"#{members}\" | grep \"address #{host_ip}$\""
  end
  members << "address #{host_ip}\n"
end

### Configure BGP router info
bgp_peers.each do |bgp_info|
  bash "Doing BGP entry for: router=#{bgp_info['router-name']}  port-ip=#{bgp_info['port-ip']}" do
    code <<-EOH
      ROUTER_ID=`#{midonet_command_prefix} -e router list name #{bgp_info['router-name']} | grep #{bgp_info['router-name']} | awk '{print $2}'`
      PORT_INFO=`#{midonet_command_prefix} -e router $ROUTER_ID list port`
      if [ `echo "$PORT_INFO" | grep #{bgp_info['port-ip']} | grep port | awk '{print $2}'` ]; then
         PORT_ID=`echo "$PORT_INFO" | grep #{bgp_info['port-ip']} | grep port | awk '{print $2}'`
      else
         echo "PORT not found on router:#{bgp_info['router-name']} for \"#{bgp_info['port-ip']}\""
         exit 1
      fi
      BGP_INFO=`#{midonet_command_prefix} -e router $ROUTER_ID port $PORT_ID list bgp`
      if [ `echo "$BGP_INFO" | grep "#{bgp_info['local-as']}\\|^$" | grep  "#{bgp_info['remote-as']}\\|^$" | awk '{print $2}'` ]; then
        BGP_ID=`echo "$BGP_INFO" | grep  "#{bgp_info['remote-as']}\\|^$" | awk '{print $2}'`
        echo "Found existing BGP entry"
      else
        echo "Adding new BPG entry for router: #{bgp_info['router-name']}"
        BGP_ID=`#{midonet_command_prefix} -e router $ROUTER_ID port $PORT_ID bgp add local-AS #{bgp_info['local-as']} peer-AS #{bgp_info['remote-as']} peer #{bgp_info['peer-address']}`
        if [ "x$BGP_ID" == "x" ]; then
          echo "BGP ID NOT RETRIEVED FROM midonet-cli add command?"
          exit 1
        fi
      fi
      ROUTES=`#{midonet_command_prefix} -e router $ROUTER_ID port $PORT_ID bgp $BGP_ID list route`
      bgp_route="net #{bgp_info['route']}$"
      if [ `echo "$ROUTES" | grep "$bgp_route"` ]; then
        AD_ROUTE=`echo "$ROUTES" | grep "$bgp_route"`
        echo "Found existing BGP route: $AD_ROUTE"
      else
        AD_ROUTE=`#{midonet_command_prefix} -e router $ROUTER_ID port $PORT_ID bgp $BGP_ID add route net #{bgp_info['route']}`
        echo "Added new BGP route: $AD_ROUTE"
        echo "Found existing BGP route: $AD_ROUTE"
      fi 
    EOH
    flags '-xe'
    retries 10
    retry_delay 20
  end
end unless bgp_peers.nil?
