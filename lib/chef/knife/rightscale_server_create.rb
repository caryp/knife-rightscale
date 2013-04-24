#
# Author:: Cary Penniman (<cary@rightscale.com>)
# Copyright:: Copyright (c) 2013 RightScale, Inc.
# License:: Apache License, Version 2.0
#
# This file is modified from the knife-ec2 plugin project code 
# That project is located at https://github.com/opscode/knife-ec2
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Copyright:: Copyright (c) 2010-2011 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/knife/rightscale_base'

class Chef
  class Knife
    class RightscaleServerCreate < Knife

      include Knife::RightscaleBase

      deps do
        require 'right_api_client'
      end

      banner "knife rightscale server create (options)"

      @@inputs = { }

      option :cloud_name,
        :short => "-c CLOUD",
        :long => "--cloud CLOUD",
        :description => "What cloud to create the server for (ec2, rackspace, gce, azure, cloudstack, openstack, etc.)",
        :proc => Proc.new { |f| Chef::Config[:knife][:cloud_name] = f },
        :default => "ec2"

      option :server_template,
        :short => "-s NAME",
        :long => "--server-template NAME",
        :description => "The name of the ServerTemplate or ID to use for the server",
        :proc => Proc.new { |i| Chef::Config[:knife][:server_template] = i },
        :required => true

      option :server_name,
        :short => "-n SERVERNAME",
        :long => "--name SERVERNAME",
        :description => "The name for the server to create",
        :proc => Proc.new { |i| Chef::Config[:knife][:server_name] = i },
        :default => "knife_provisioned"

      option :deployment_name,
        :short => "-d NAME",
        :long => "--deployment NAME",
        :description => "The name of the deployment to place the server in",
        :proc => Proc.new { |i| Chef::Config[:knife][:deployment_name] = i },
        :default => "default"

      option :server_inputs,
        :short => "-j JSON",
        :long => "--json-inputs JSON",
        :description => "A JSON string of server input values",
        :proc => lambda { |o| JSON.parse(o) }

      option :input,
        :short => "-i NAME:VALUE",
        :long => "--input NAME:VALUE",
        :description => "An input name and value",
        :proc => lambda { |o| k,v=o.split(":",2); @@inputs[k]=v }
      
      option :ssh_key_name,
        :short => "-S KEY_UUID",
        :long => "--ssh-key KEY_UUID",
        :description => "The AWS SSH key resource UUIS",
        :proc => Proc.new { |key| Chef::Config[:knife][:ssh_key_uuid] = key }
        
      # Gets applied to chef/client/roles input of ServerTemplate, if it exists
      # option :run_list,
      #   :short => "-r RUN_LIST",
      #   :long => "--run-list RUN_LIST",
      #   :description => "Comma separated list of roles/recipes to apply.",
      #   :proc => lambda { |o| o.split(/[\s,]+/) }
      # 
      # option :json_attributes,
      #   :short => "-j JSON",
      #   :long => "--json-attributes JSON",
      #   :description => "A JSON string to be added to the first run of chef-client",
      #   :proc => lambda { |o| JSON.parse(o) }
      #
      # option :bootstrap_version,
      #   :long => "--bootstrap-version VERSION",
      #   :description => "The version of Chef to install",
      #   :proc => Proc.new { |v| Chef::Config[:knife][:bootstrap_version] = v }
      # 
      # option :chef_node_name,
      #   :short => "-N NAME",
      #   :long => "--node-name NAME",
      #   :description => "The Chef node name for your new node",
      #   :proc => Proc.new { |key| Chef::Config[:knife][:chef_node_name] = key }
      #
      # option :flavor,
      #   :short => "-f FLAVOR",
      #   :long => "--flavor FLAVOR",
      #   :description => "The flavor of server (m1.small, m1.medium, etc)",
      #   :proc => Proc.new { |f| Chef::Config[:knife][:flavor] = f }
      # 
      # option :image,
      #   :short => "-I IMAGE",
      #   :long => "--image IMAGE",
      #   :description => "The AMI for the server",
      #   :proc => Proc.new { |i| Chef::Config[:knife][:image] = i }
      # 
      option :security_groups,
              :short => "-G X,Y,Z",
              :long => "--groups X,Y,Z",
              :description => "The security groups for this server; not allowed when using VPC",
              :proc => Proc.new { |groups| groups.split(',') }

      def run
        $stdout.sync = true

        validate!

        # create and launch server
        print "#{ui.color("Provisioning server with RightScale.", :green)}"
        print "\n#{ui.color("ServerTemplate:", :magenta)} #{config[:server_template]}"
        print "\n#{ui.color("Server name:", :magenta)} #{config[:server_name]}"
        print "\n#{ui.color("Cloud:", :magenta)} #{config[:cloud_name]}"
        print "\n#{ui.color("Deployment name:", :magenta)} #{config[:deployment_name]}"
        print "\n#{ui.color("Inputs:", :magenta)} #{@@inputs}"
        print "\n"
        
        rightscale = ::RightApiProvision::Provisioner.new(connection)
        rightscale.provision(
          config[:server_template], 
          config[:server_name], 
          config[:cloud_name], 
          config[:deployment_name],
          @@inputs,
          config[:ssh_key_name],
          config[:security_groups]
        )
        
        if rightscale.server_ready?
          print "#{ui.color("Server already running", :green)}"
        else
          print "\n#{ui.color("Waiting for RightScale to configure server\n", :yellow)}"
          rightscale.wait_for_operational
          print "\n"
        end
        
        # output connection information
        print "#{ui.color("Querying server info...\n", :magenta)}"
        info = rightscale.server_info
        print "\n"
        msg_pair("Public DNS Name", info.public_dns_names.first)
        msg_pair("Public IP Address", info.public_ip_addresses.first)
        msg_pair("Private DNS Name", info.private_dns_names.first)
        msg_pair("Private IP Address", info.private_ip_addresses.first)
      end

    private

      def validate!
        super([:cloud_name, :deployment_name, :server_template, :rightscale_user, :rightscale_password, :rightscale_account_id])
      end

    end
  end
end
