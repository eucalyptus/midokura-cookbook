default['midokura']['repo-username'] = ''
default['midokura']['repo-password'] = ''
default['cassandra']['repo-url'] = 'http://rpm.datastax.com/community'
default['cassandra']['package'] = 'dsc20'
default['cassandra']['cluster_name'] = 'midonet'
# default['cassandra']['version'] = '2.0.9'
# default['cassandra']['release'] = '1'
# default['cassandra']['metrics_reporter'] = {'config' => {}}
default['midokura']['yum-options'] = '--nogpgcheck'
default['midokura']['repo-url']= 'http://repo.midonet.org/midonet/current/RHEL/6/stable/'
default['midokura']['misc-repo-url']= 'http://repo.midonet.org/misc/RHEL/6/misc/'
default['midokura']['midonet-api-url'] = 'http://127.0.0.1:8080/midonet-api'
default['midokura']['gpgcheck'] = false
default['midokura']['cassandras'] = []
# Example:
# default['midokura']['cassandras'] = ['<hostname or ip>']

default['midokura']['zookeepers'] = []
# Example:
# default['midokura']['zookeepers'] = ['<hostname or ip>:2181']

default['midokura']['zookeeper']['java_home'] = '/usr/lib/jvm/jre/'
default['midokura']['zookeeper']['logpath'] = '/var/log/zookeeper'

# Examples
# default['midokura']['midolman-host-mapping'] = {'default-centos-65.vagrantup.com' => '127.0.0.1'}
# default['midokura']['midolman-host-mapping'] = {'machine1.qa1.eucalyptus-systems.com' => '1.2.3.4',
#						'machine2.qa1.eucalyptus-systems.com' => '1.2.3.5'}
# default['midokura']['bgp-peers'] = [{ 'router-name': 'eucart',
#                                       'port-ip': '10.116.129.5',
#                                       'remote-as': 65000,
#                                       'local-as': 65001,
#                                       'peer-address': '10.116.133.173',
#                                       'route': '10.116.130.0/24'
#                                     }]
default['midokura']['initial-tenant'] = 'mido_tenant'
default['midokura']['default-tunnel-zone'] = 'mido-tz'
default['midokura']['auth-auth_provider'] = 'org.midonet.cluster.auth.MockAuthService'
default['midokura']['keystone-service_protocol'] = 'http'
default['midokura']['keystone-service_host'] = '127.0.0.1'
default['midokura']['keystone-service_port'] = 35357
default['midokura']['keystone-service_port'] = '999888777666'
default['midokura']['keystone-tenant_name'] = 'admin'
default['zookeeper']['libsdir'] = '/var/lib/zookeeper'
default['zookeeper']['server-index'] = nil
# uninstall attribute controls whether we retain or destroy
# config files during nuke recipe
default['zookeeper']['uninstall']['destroy'] = true
default['cassandra']['uninstall']['destroy'] = true
default['midokura']['uninstall']['destroy'] = true
default['tomcat']['jvm']['memory'] = '1g'
