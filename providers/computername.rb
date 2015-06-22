#
# Cookbook Name:: fqdn
# Provider:: computername
#
# Copyright 2015, Lonnie VanZandt
#
# All rights reserved - Do Not Redistribute
#

require 'chef/dsl/registry_helper'

def whyrun_supported?
  true
end

action :add do

  converge_by("add new Fully Qualified Domain Name #{new_resource.host} for computer #{new_resource.name}") do

    powershell_script "netdom computername" do
      code <<-EOH
        netdom computername #{new_resource.name} /add:#{new_resource.host}
      EOH
    end

    Chef::Log.info("#{new_resource} added #{new_resource.host} for #{new_resource.name}")
  end

  new_resource.updated_by_last_action(true)
end

action :add_primary do

  unless new_resource.host.casecmp( activeFqdn() )

    converge_by("add new primary Fully Qualified Domain Name #{new_resource.host} for computer #{new_resource.name}") do
  
      reboot "New ComputerName" do
        action :nothing
        reason "The new primary computername #{new_resource.host} needs a reboot to become effective."
      end
      
      powershell_script "netdom computername" do
        code <<-EOH
          netdom computername #{new_resource.name} /add:#{new_resource.host}
          netdom computername #{new_resource.name} /makeprimary:#{new_resource.host}
        EOH
        
        notifies new_resource.reboot_immediately ? :reboot_now : :request_reboot, 'reboot[New ComputerName]', :immediately
      end
  
      Chef::Log.info("#{new_resource} added primary #{new_resource.host} for #{new_resource.name}")
    end
    
    new_resource.updated_by_last_action(true)
  end
end

def activeFqdn()
  
  hostname = Chef::DSL::RegistryHelper::registry_get_values( 
    "HKLM\\SYSTEM\\CurrentControlSet\\Control\\ComputerName\\ActiveComputerName" ).select { |v| v[:name] == "ComputerName" }[0][:data]
  domain   = Chef::DSL::RegistryHelper::registry_get_values(
    "HKLM\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters" ).select { |v| v[:name] == "Domain" }[0][:data]
  
  "#{hostname}.#{domain}"  
end
