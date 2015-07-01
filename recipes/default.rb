#
# Cookbook Name:: dnssuffix
# Recipe:: default
#
# Copyright 2015, Lonnie VanZandt
#
# All rights reserved - Do Not Redistribute
#

# make sure that the server has the DNS domain we expect and reboot if needed
dnssuffix_domain node['dnssuffix']['domain'] do
  action :add
  
  host node['dnssuffix']['host']
    
  reboot_immediately true
end
