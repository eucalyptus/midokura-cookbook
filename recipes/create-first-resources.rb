midonet_url = node['midokura']['midonet-api-url']
tunnel_zone_name = node['midokura']['default-tunnel-zone']
initial_tenant = node['midokura']['initial-tenant']
bgp_peers = node['midokura']['bgp-peers']

midonet_command_prefix = "midonet-cli --midonet-url=#{midonet_url} -A"

execute 'Create TunnelZone' do
  command "#{midonet_command_prefix} -e add tunnel-zone name #{tunnel_zone_name} type gre"
  retries 20
  retry_delay 10
  not_if "#{midonet_command_prefix} -e list tunnel-zone | grep #{tunnel_zone_name}"
end

### Add hosts to tunnel zone
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
    not_if "#{midonet_command_prefix} -e list tunnel-zone name #{tunnel_zone_name} member | grep #{host_ip}"
  end
end

bash 'Initialize Tenant' do
  code <<-EOH
  BRIDGE=`#{midonet_command_prefix} --tenant #{initial_tenant} -e add bridge name foo`
  #{midonet_command_prefix} --tenant #{initial_tenant} -e delete bridge $BRIDGE
  EOH
  flags '-xe'
  retries 10
  retry_delay 20
end

bgp_peers.each do |bgp_info|
  bash "Peer BGP: router=#{bgp_info['router-name']}  port-ip=#{bgp_info['port-ip']}" do
    code <<-EOH
      ROUTER_ID=`#{midonet_command_prefix} -e router list name #{bgp_info['router-name']} | awk '{print $2}'`
      PORT_ID=`#{midonet_command_prefix} -e router id $ROUTER_ID list port | grep #{bgp_info['port-ip']} | awk '{print $2}'`
      BGP_ID=`#{midonet_command_prefix} -e router $ROUTER_ID port $PORT_ID bgp add local-AS #{bgp_info['local-as']} peer-AS #{bgp_info['remote-as']} peer #{bgp_info['peer-address']}`
      #{midonet_command_prefix} -e router $ROUTER_ID port $PORT_ID bgp $BGP_ID add route net #{bgp_info['route']}
    EOH
    flags '-xe'
    retries 10
    retry_delay 20
  end
end unless bgp_peers.nil?