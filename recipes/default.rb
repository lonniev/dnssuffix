#
# Cookbook Name:: netdom
# Recipe:: default
#
# Copyright 2015, Lonnie VanZandt
#
# All rights reserved - Do Not Redistribute
#

# make sure that the server has the FQDN we expect and reboot if needed
netdom_domain node['netdom']['host'] do
  action :make_primary
  computer node['netdom']['alias']
  reboot_immediately true
end
