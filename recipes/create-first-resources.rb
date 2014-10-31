midonet_url = node['midokura']['midonet-api-url']
tunnel_zone_name = node['midokura']['default-tunnel-zone']

midonet_command_prefix = "midonet-cli --midonet-url=#{midonet_url} -A"

execute 'Create TunnelZone' do
  command "#{midonet_command_prefix} -e add tunnel-zone name #{tunnel_zone_name} type gre"
  retries 20
  retry_delay 10
  not_if "#{midonet_command_prefix} -e list tunnel-zone | grep #{tunnel_zone_name}"
end

### Add hosts to tunnel zone
midolmen = node['midokura']['midolman-host-mapping']
log "Midolmen: #{midolmen}"
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
  end
end

bash 'Initialize Tenant' do
  code <<-EOH
  BRID=`#{midonet_command_prefix} --tenant euca_tenant_1 -e add bridge name foo `
  #{midonet_command_prefix} --tenant euca_tenant_1 -e delete bridge $BRID
  EOH
  flags '-xe'
  retries 10
  retry_delay 20
end