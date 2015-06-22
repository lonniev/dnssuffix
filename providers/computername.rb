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

action :add do

  converge_by("add new Fully Qualified Domain Name #{new_resource.host}") do

    powershell_script "cwd-to-win-env-var" do
      cwd "%TEMP%"
      code <<-EOH
        netdom computername #{new_resource.name} add:
      EOH
    end

    Chef::Log.info("#{new_resource} retrieved #{mediaFilePath} for #{new_resource.purpose}")
  end

  new_resource.updated_by_last_action(true)
end
