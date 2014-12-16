#
# Cookbook Name:: midokura
# Recipe:: _common
#
# Copyright (C) 2014
#
#
#
include_recipe 'yum'
include_recipe 'yum-epel'

yum_repository "midokura-main" do
  action :create
  description "midokura Package Repo"
  url node["midokura"]["repo-url"]
  gpgcheck node["midokura"]["gpgcheck"]
  metadata_expire "1"
end

yum_repository "midokura-misc" do
  action :create
  description "midokura Misc Package Repo"
  url node["midokura"]["misc-repo-url"]
  gpgcheck node["midokura"]["gpgcheck"]
  metadata_expire "1" 
end
