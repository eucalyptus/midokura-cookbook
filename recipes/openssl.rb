include_recipe 'yum-epel'
package "openssl-devel" do
  options node['midokura']['yum-options']
end 
