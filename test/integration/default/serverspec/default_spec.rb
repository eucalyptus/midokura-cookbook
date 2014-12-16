require 'serverspec'

set :backend, :exec

describe "Midokura Default" do
  ### Ensure packages are installed
  %w{zookeeper dsc20 tomcat6 midolman}.each do |package_name|
       describe package(package_name) do
         it { should be_installed }
       end
  end

  ### Ensure services are enabled (midolman does not allow itself to be enabled)
  %w{zookeeper cassandra tomcat6}.each do |service_name|
     describe service(service_name) do
       it { should be_enabled }
       it { should be_running }
     end
  end
  describe service('midolman') do
    it { should be_running }
  end

  ### Ensure ports are open for:
  ### midonet-api midonet-cp zookeeper cassandra
  %w{8080 2181 9160 7199 9042 7000}.each do |port_number|
     describe port(port_number) do
       it { should be_listening }
     end
  end

  ### Check midonet-api
  describe command('curl http://localhost:8080/') do
    its(:exit_status) { should eq 0 }
  end
  describe command('curl http://localhost:8080/midonet-api/') do
    its(:exit_status) { should eq 0 }
  end
end
