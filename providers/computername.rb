#
# Cookbook Name:: fqdn
# Provider:: computername
#
# Copyright 2015, Lonnie VanZandt
#
# All rights reserved - Do Not Redistribute
#

def whyrun_supported?
  true
end

def load_current_resource
  @current_resource = Chef::Resource::FqdnComputername.new( @new_resource.name )
  
  @current_resource.computername(@new_resource.computername)
  @current_resource.name(@new_resource.name)

  @current_resource.exists = fqdn_added?( @current_resource.name )
  
  @current_resource
end
 
action :add do

  unless fqdn_added?( new_resource.name )

    converge_by("add new Fully Qualified Domain Name #{new_resource.name} for computer #{new_resource.computername}") do

      powershell_script "netdom computername" do
        code <<-EOH
          netdom computername #{new_resource.computername} /add:#{new_resource.name}
        EOH
      end

      Chef::Log.info("#{new_resource} added #{new_resource.name} for #{new_resource.computername}")
    end

  end
end

action :add_primary do

  unless fqdn_added?( new_resource.name )

    converge_by("add new primary Fully Qualified Domain Name #{new_resource.name} for computer #{new_resource.computername}") do

      reboot "New ComputerName" do
        action :nothing
        reason "The new primary computername #{new_resource.name} needs a reboot to become effective."
      end

      powershell_script "netdom computername" do
        code <<-EOH
          netdom computername #{new_resource.computername} /add:#{new_resource.name}
          netdom computername #{new_resource.computername} /makeprimary:#{new_resource.name}
        EOH

        notifies new_resource.reboot_immediately ? :reboot_now : :request_reboot, 'reboot[New ComputerName]', :immediately
      end

      Chef::Log.info("#{new_resource} added primary #{new_resource.name} for #{new_resource.computername}")
    end

  end
end

action :make_primary do

  unless fqdn_active?( new_resource.name )

    converge_by("make primary Fully Qualified Domain Name #{new_resource.name} for computer #{new_resource.computername}") do

      reboot "New ComputerName" do
        action :nothing
        reason "The new primary computername #{new_resource.name} needs a reboot to become effective."
      end

      powershell_script "netdom computername" do
        code <<-EOH
          netdom computername #{new_resource.computername} /add:#{new_resource.name}
        EOH       
      end unless fqdn_added?( new_resource.name )
      
      powershell_script "netdom computername" do
        code <<-EOH
          netdom computername #{new_resource.computername} /makeprimary:#{new_resource.name}
        EOH

        notifies new_resource.reboot_immediately ? :reboot_now : :request_reboot, 'reboot[New ComputerName]', :immediately
      end

      Chef::Log.info("#{new_resource} made primary #{new_resource.name} for #{new_resource.computername}")
    end

  end
end

def registry_get_values(key_path, architecture = :machine)
  registry = Chef::Win32::Registry.new(run_context, architecture)
  registry.get_values(key_path)
end

def fqdn_added?( fqdn )

  begin
    hostname = registry_get_values(
    "HKLM\\SYSTEM\\CurrentControlSet\\Control\\ComputerName\\ComputerName" ).select { |v| v[:name] == "ComputerName" }[0][:data]
    domain   = registry_get_values(
    "HKLM\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters" ).select { |v| v[:name] == "Domain" }[0][:data]

    Chef::Log.warn( "Given #{fqdn}, looked up #{hostname}.#{domain}" )
    
    fqdn.casecmp( "#{hostname}.#{domain}" ).zero?
  rescue
    false
  end
end

def fqdn_active?( fqdn )

  return false if !fqdn_added?( fqdn )

  begin
    hostname = registry_get_values(
    "HKLM\\SYSTEM\\CurrentControlSet\\Control\\ComputerName\\ActiveComputerName" ).select { |v| v[:name] == "ComputerName" }[0][:data]
    domain   = registry_get_values(
    "HKLM\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters" ).select { |v| v[:name] == "Domain" }[0][:data]

    fqdn.casecmp( "#{hostname}.#{domain}" ).zero?
  rescue
    false
  end
end
