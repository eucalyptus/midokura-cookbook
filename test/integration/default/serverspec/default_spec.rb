require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.before :all do
    c.path = '/sbin:/usr/sbin'
  end
end

describe "Midokura Default" do
  ### Ensure packages are installed
  %w{zookeeper dsc20 tomcat6 httpd midolman midonet-cp}.each do |package_name|
       describe package(package_name) do
         it { should be_installed }
       end
  end

  ### Ensure services are enabled (midolman does not allow itself to be enabled)
  %w{zookeeper cassandra httpd tomcat6}.each do |service_name|
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
  %w{8080 80 2181 9160 7199 9042 7000}.each do |port_number|
     describe port(port_number) do
       it { should be_listening }
     end
  end

  ### Check midonet-api
  describe command('curl http://localhost:8080/') do
    it { should return_exit_status 0 }
  end
  describe command('curl http://localhost:8080/midonet-api/') do
    it { should return_exit_status 0 }
  end

  ### Check midonet-cp
  describe command('curl http://localhost/midonet-cp/') do
    it { should return_exit_status 0 }
  end
end
