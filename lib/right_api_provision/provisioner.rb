#
# Author:: Cary Penniman (<cary@rightscale.com>)
# Copyright:: Copyright (c) 2013 RightScale, Inc.
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

module RightApiProvision
  class Provisioner
    
    BAD_STATES_UP = [ "stranded", "terminated"]
    
    def initialize(rightscale_api_object)
      raise "ERROR: you must supply an valid RightScale API object" unless rightscale_api_object
      @rsapi = rightscale_api_object
    end
    
    def provision(servertemplate, 
                  server_name = "default", 
                  cloud_name = "ec2", 
                  deployment_name = "default", 
                  inputs = nil,
                  ssh_key_uuid = nil,
                  security_groups = nil)

      # fail if the requested cloud is not registered with RightScale account
      @cloud = @rsapi.find_cloud_by_name(cloud_name)
      raise "ERROR: cannot find a cloud named: '#{cloud_name}'. " +
            "Please check the spelling of the 'cloud_name' parameter " + 
            "and verify the cloud is registered with " + 
            "your RightScale account?" unless  @cloud
            
      # Verify ssh key uuid, if required by cloud
      if @rsapi.requires_ssh_keys?(@cloud)
        @ssh_key = @rsapi.find_ssh_key_by_uuid_or_first(@cloud, ssh_key_uuid)
        raise "ERROR: cannot find an ssh_key named: #{ssh_key_uuid}" unless @ssh_key
      end
      
      # Verify security group, if required by cloud
      if @rsapi.requires_security_groups?(@cloud)
        @sec_groups = []
        security_groups ||= ["default"]
        security_groups.each do |name|
          group = @rsapi.find_security_group_by_name(@cloud, name)
          raise "ERROR: cannot find an security group named: #{name}" unless group
          @sec_groups << group
        end
      end

      # check for existing deployment and server in RightScale account
      @deployment = @rsapi.find_deployment_by_name(deployment_name)
      puts "Deployment '#{deployment_name}' #{@deployment ? "found." : "not found."}" 
      @server = @rsapi.find_server_by_name(server_name) if @deployment 
      puts "Server '#{server_name}' #{@server ? "found." : "not found."}"

      if @server
        # verify existing server is on the cloud we are requesting, if not fail.
        actual_cloud_name = @rsapi.server_cloud_name(@server)
        raise "ERROR: the server is in the '#{actual_cloud_name}' cloud, " +
              "and not in the requested '#{cloud_name}' cloud.\n" +
              "Please delete the server or pick and new server name." if cloud_name != actual_cloud_name
      end
    
      unless @deployment && @server
        # we need to create a server, can we find the servertemplate?
        @servertemplate = @rsapi.find_servertemplate(servertemplate)
        raise "ERROR: cannot find ServerTemplate '#{servertemplate}'. Did you import it?\n" + 
              "Visit http://bit.ly/VnOiA7 for more info.\n\n" unless  @servertemplate        
        # can we find the MCI?
        #TODO: @mci = @rsapi.find_multicloudimage_by_name(@servertemplate, config.multi_cloud_image_name)
      end

      # create deployment and server as needed
      unless @deployment
        @deployment = @rsapi.create_deployment(deployment_name)
        puts "Created deployment."
      end

      unless @server
        @server = @rsapi.create_server(@deployment, @servertemplate, @mci, @cloud, server_name, @ssh_key, @sec_groups)
        puts "Created server."
      end

      unless @rsapi.is_provisioned?(@server)

        # setup any inputs
        @rsapi.set_server_inputs(@server, inputs) if inputs

        # launch server
        puts "Launching server..."
        @server = @rsapi.launch_server(@server, inputs)
        @rsapi.set_bad_states(BAD_STATES_UP)
        @rsapi.server_wait_for_state(@server, "booting", 30)
      end

      # if cloud_name == VAGRANT_CLOUD_NAME
      #   # Vagrant box: grab "Data request URL" from UserData
      #   user_data = @server.current_instance.show(:view => "full").user_data
      #   puts user_data.inspect
      #   @data_request_url = @rsapi.data_request_url(user_data)
      #   puts "Data Request URL: #{@data_request_url}"
      # else
      #   @rsapi.server_wait_for_state(server_name, "operational", 30)
      # end

    end
   
    def server_ready?
      @rsapi.server_ready?(@server)
    end
     
    def wait_for_operational
      @rsapi.set_bad_states(BAD_STATES_UP)
      @rsapi.server_wait_for_state(@server, "operational", 30)
    end
    
    def server_info
      info = @rsapi.server_info(@server)
      while info.private_ip_addresses.empty?
        puts "Waiting for cloud to provide IP address..."
        sleep 30
        info = @rsapi.server_info(@server)
      end
      info
    end
    
  end
end