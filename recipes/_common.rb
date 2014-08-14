#
# Cookbook Name:: midokura
# Recipe:: _common
#
# Copyright (C) 2014
#
#
#
include_recipe 'yum-epel'
if node["midokura"]["repo-username"] == ''
  raise "Please set the Midokura repo username attribute in your environment: midokura->repo-username"
end
if node["midokura"]["repo-password"] == ''
  raise "Please set the Midokura repo password attribute in your environment: midokura->repo-password"
end
template "/etc/yum.repos.d/midokura.repo" do
  source "midokura.repo.erb"
  mode 0440
  owner "root"
  group "root"
end
