#
# Cookbook Name:: fqdn
# Resource:: computername
#
# Copyright 2015, Lonnie VanZandt
#
# All rights reserved - Do Not Redistribute
#

actions :add, :add_primary, :make_primary
default_action :add

attribute :computername, kind_of: String, :required => true
attribute :host, kind_of: String, name_attribute: true
attribute :reboot_immediately, kind_of: [TrueClass,FalseClass], :default => false

attr_accessor :exists