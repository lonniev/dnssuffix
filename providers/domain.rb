#
# Cookbook Name:: dnssuffix
# Provider:: domain
#
# Copyright 2015, Lonnie VanZandt
#
# All rights reserved - Do Not Redistribute
#

def whyrun_supported?
  true
end

def load_current_resource
  @current_resource = Chef::Resource::DnssuffixDomain.new( @new_resource.name )
  
  @current_resource.host(@new_resource.host)

  @current_resource.exists = domain_exists?( @current_resource.name )
  
  @current_resource
end
 
action :add do

  unless @current_resource.exists
    
    dns = @new_resource.name
    host = @new_resource.host
    reboot_action = @new_resource.reboot_immediately ? :reboot_now : :request_reboot

    converge_by("add new Domain Name Suffix #{dns} for computer #{host}") do

      registry_key "HKLM\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters" do
        
        values [{
          :name => "Domain",
          :type => :string,
          :data => "#{dns}"
        }]
        
        action :create

        notifies reboot_action, "reboot[New DNS Suffix #{dns}]", :immediately

      end

      reboot "New DNS Suffix #{dns}" do
        action :nothing
        reason "The new DNS #{dns} needs a reboot to become effective."
      end
      
      Chef::Log.info("#{@new_resource} added #{dns} for #{host}")
    end

  end
end

def domain_exists?( dns )

  begin
    
    domains   = registry_get_values(
      "HKLM\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters"
    ).select { |v| v[:name] == "Domain" }

    domains.any? { |v| dns.casecmp( v[:data] ).zero? }
    
  rescue
    
    false
    
  end
end

def registry_get_values(key_path, architecture = :machine)
  registry = Chef::Win32::Registry.new(run_context, architecture)
  registry.get_values(key_path)
end