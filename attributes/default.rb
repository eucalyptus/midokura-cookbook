default['midokura']['repo-username'] = ''
default['midokura']['repo-password'] = ''
default['java']['jdk_version'] = '7'
default['java']['install_flavor'] = 'openjdk'
default['java']['set_default'] = true
default['cassandra']['cluster_name'] = 'midonet'
#default['cassandra']['version'] = '2.0.9'
default['cassandra']['release'] = '1'
default['cassandra']['metrics_reporter'] = {'config' => {}}
default['thrift']['version']  = '0.9.0'
#default['thrift']['checksum'] = 'ac175080c8cac567b0331e394f23ac306472c071628396db2850cb00c41b0017'
default['thrift']['mirror']   = 'http://archive.apache.org/dist/'
default['tomcat']['port'] = 8080
default['midokura']['yum-options'] = '--nogpgcheck'
default['midokura']['repo-url']= 'http://repo.midonet.org/midonet/v2014.11/RHEL/6/testing/'
default['midokura']['misc-repo-url']= 'http://repo.midonet.org/misc/RHEL/6/misc/'
default['midokura']['midonet-api-url'] = 'http://127.0.0.1:8080/midonet-api'
default['midokura']['gpgcheck'] = false
default['midokura']['cassandras'] = ['127.0.0.1:9160']
default['midokura']['zookeepers'] = ['127.0.0.1:2181']
default['midokura']['tomcat-url'] = "<param-value>http://<%= node['fqdn'] %>:8080/midonet-api</param-value>"
#default['midokura']['midolman-host-mapping'] = {'default-centos-65.vagrantup.com' => '127.0.0.1'}
#default['midokura']['midolman-host-mapping'] = {'machine1.qa1.eucalyptus-systems.com' => '1.2.3.4',
#						'machine2.qa1.eucalyptus-systems.com' => '1.2.3.5'}
#default['midokura']['bgp-peers'] = [{ 'router-name': 'eucart',
#                                      'port-ip': '10.116.129.5',
#                                      'remote-as': 65000,
#                                      'local-as': 65001,
#                                      'peer-address': '10.116.133.173',
#                                      'route': '10.116.130.0/24'
#                                    }]
default['midokura']['initial-tenant'] = 'mido_tenant'
default['midokura']['default-tunnel-zone'] = 'mido-tz'
default['midokura']['auth-auth_provider'] = 'org.midonet.api.auth.MockAuthService'
default['midokura']['keystone-service_protocol'] = 'http'
default['midokura']['keystone-service_host'] = '127.0.0.1'
default['midokura']['keystone-service_port'] = 35357
default['midokura']['keystone-service_port'] = '999888777666'
default['midokura']['keystone-tenant_name'] = 'admin'
