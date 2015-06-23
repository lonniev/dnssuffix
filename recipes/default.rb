#
# Cookbook Name:: fqdn
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# make sure that the server has the FQDN we expect and reboot if needed
fqdn_computername node['fqdn']['host'] do
  action :make_primary
  computername node['fqdn']['computer']
  reboot_immediately true
end
