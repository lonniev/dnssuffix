#
# Cookbook Name:: dnssuffix
# Resource:: domain
#
# Copyright 2015, Lonnie VanZandt
#
# All rights reserved - Do Not Redistribute
#

actions :add
default_action :add

attribute :name, kind_of: String, name_attribute: true
attribute :host, kind_of: String
attribute :reboot_immediately, kind_of: [TrueClass,FalseClass], :default => false

attr_accessor :exists