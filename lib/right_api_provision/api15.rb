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
  class API15

    attr_reader :client

    def initialize
      require "right_api_client"
    end

    def connection(email, password, account_id, api_url = nil)
      begin
        args = { :email => email, :password => password, :account_id => account_id }
        @url = api_url
        args[:api_url] = @url if @url
        @connection ||= RightApi::Client.new(args)
        #@logger = Logger.new(STDOUT)
        #@logger.level = Logger::DEBUG
        #@connection.log(@logger)
        @client = @connection
      rescue Exception => e
        args.delete(:password) # don't log password
        puts "ERROR: could not connect to RightScale API.  Params: #{args.inspect}" 
        puts e.message
        puts e.backtrace
        raise e
      end
    end
    
    # If the cloud reports ssh keys, then we assume it requires them to launch
    # servers.
    def requires_ssh_keys?(cloud)
      begin
        cloud.show.ssh_keys
        true
      rescue RightApi::Exceptions::ApiException => e
        false # assume cloud does not require them
      end
    end
    
    # Find SSH key
    #
    # EC2 and Eucalyptus require an SSH key to launch a server.  RightScale 
    # manages SSH keys for each user so just grabbing the first one is fine,
    # however older configurations might relay on specific keys.  You will
    # need to grab the resource UUID from the RightScale dashboard for the key
    # that you want to use.
    def find_ssh_key_by_uuid_or_first(cloud, ssh_uuid = nil)
      ssh_key = nil
      if ssh_uuid
        # grab specific ssh key
        sshkey = find_resource(:ssh_keys, :by_resource_uid, uuid)
      else
        # grab first key found
        keys = cloud.show.ssh_keys
        ssh_key = keys.index.first if keys
      end
      ssh_key
    end
    
    # If the cloud reports security groups then we assume it requires them to launch
    # servers.
    def requires_security_groups?(cloud)
       begin
        cloud.show.security_groups
        true
      rescue RightApi::Exceptions::ApiException => e
        false # assume cloud does not require them
      end
    end
    
    def user_data
      @user_data ||= @server.show.current_instance(:view=>"extended").show.user_data
    end

    def data_request_url(userdata)
      data_hash = {}
      entry = userdata.split('&').select { |entry| entry =~ /RS_rn_auth/i }
      raise "ERROR: user data token not found. " + 
            "Does your MCI have a provides:rs_agent_type=right_link tag?" unless entry
      token = entry.first.split('=')[1]
      "#{@url}/servers/data_injection_payload/#{token}" 
    end
    
    def delete_server(name)
      server = find_server_by_name(name)
      server.terminate
      begin
        server_wait_for_state(server, "terminated")
      rescue Exception => e
        
      end
      server.destroy
    end
    
    def list_servers(filter_by, filter_value)
      list_resources(:servers, filter_by, filter_value)
    end
    
    def list_deployments(filter_by, filter_value)
      list_resources(:deployments, filter_by, filter_value)
    end
    
    def list_clouds(filter_by, filter_value)
      list_resources(:clouds, filter_by, filter_value)
    end
    
    def list_servertemplates(filter_by, filter_value)
      list_resources(:server_templates, filter_by, filter_value)
    end
    
    def list_security_groups(cloud, filter_by, filter_value)
      list_subresources(cloud, :security_groups, filter_by, filter_value)
    end
    
    def list_multi_cloud_images(server_template, filter_by, filter_value)
      list_subresources(server_template, :multi_cloud_images, filter_by, filter_value)
    end
    
    def find_security_group_by_name(cloud, security_group_name)
      find_cloud_resource(cloud, :security_groups, :by_name, security_group_name)
    end

    def find_server_by_name(name)
      find_resource(:servers, :by_name, name)
    end

    def find_deployment_by_name(name)
      find_resource(:deployments, :by_name, name)
    end

    # returns:: String if cloud is found, nil if not found
    def find_cloud_by_name(name)
      find_resource(:clouds, :by_name, name)
    end

    def find_mci_by_name(server_template, mci_name)
      find_resource(:mcis, :by_name, name)
    end

    def find_servertemplate(name_or_id)
      server_template = nil; id = nil; name = nil

      # detect if user passed in a name or an id
      # there is probably a cleaner way to do this, but I am lazy ATM.
      begin
        id = Integer(name_or_id)
      rescue Exception => e
        name = name_or_id # Cannot be case to integer, assume a name was passed
      end

      if name 
        # find ServerTemplate by name
        st_list = list_resources(:server_templates, :by_name, name)
        revisions = st_list.map { |st| st.revision }

        # check for duplicate revisions
        duplicates = (revisions.size != revisions.uniq.size)
        raise "ERROR: Duplicate ServerTemplate with the name of '#{name}' detected " +
                  "in account -- there can be only one. Please fix via the RightScale dashboard and retry." if duplicates
        
        # always use latest revision
        latest_rev = revisions.sort.last
        server_template = st_list.select { |st| st.revision == latest_rev}.first
      else
        # find ServerTemplate by id
        server_template = @connection.server_templates.index(:id => id)
      end

      server_template
    end

    def create_deployment(name)
      @connection.deployments.create(:deployment => { :name => name, :decription => "Created by the Vagrant"})
    end

    def destroy_deployment(deployment)
      deployment.destroy
    end

    def create_server(deployment, server_template, mci, cloud, name, ssh_key = nil, groups = nil)

      #TODO: mci param not used yet

      # check params
      unless st_href = server_template.show.href 
        raise "ERROR: ServerTemplate parameter not initialized properly"
      end

      unless d_href = deployment.show.href 
        raise "ERROR: Deployment parameter not initialized properly"
      end

      unless c_href = cloud.show.href 
        raise "ERROR: Deployment parameter not initialized properly"
      end
      
      if ssh_key 
        unless ssh_key_href = ssh_key.show.href 
          raise "ERROR: ssh_key parameter not initialized properly"
        end
      end

      security_group_hrefs = nil
      if groups 
        security_group_hrefs = []
        groups.each do |group|
          unless group_href = group.show.href 
            raise "ERROR: ssh_key parameter not initialized properly"
          end
          security_group_hrefs << group_href
        end
      end
      
      instance_hash = {
        :cloud_href => c_href, 
        :server_template_href => st_href
      }
      instance_hash[:ssh_key_href] = ssh_key_href if ssh_key
      instance_hash[:security_group_hrefs] = security_group_hrefs if security_group_hrefs


      # create server in deployment using specfied ST
      server = 
        @connection.servers.create({
              :server => { 
              :name => name, 
              :decription => "Created by the Vagrant",
              :deployment_href => d_href,
              :instance => instance_hash
            } 
          })
    end

    def is_provisioned?(server)
      server.show.api_methods.include?(:current_instance)
    end

    # @param(Hash) inputs Hash input name/value pairs i.e. { :name => "text:dummy"}
    def launch_server(server, inputs = { :name => "text:dummy"})
      server_name = server.show.name
      server.launch(inputs) # TODO: parse inputs from Vagrantfile
      # XXX: need to create a new server object after launch -- why? API bug?
      find_server_by_name(server_name) 
    end

    def terminate_server(server)
      server.terminate
    end

    # Only use this *before* you launch the server
    def set_server_inputs(server, inputs)
      server.show.next_instance.show.inputs.multi_update({"inputs" => inputs})
    end

    def server_wait_for_state(server, target_state, delay = 10)
      current_state = server_state(server)
      while current_state != target_state
        raise "Unexpected sever state: #{current_state}" if is_bad?(current_state)
        puts "Server #{current_state}. Waiting for instance to be in #{target_state} state..."
        sleep delay
        current_state = server_state(server)
      end
    end
    
    def set_bad_states(list_array)
      @bad_states = list_array
    end

    def is_bad?(state)
      @bad_states ||= []
      @bad_states.select{|s| state =~ /#{s}/}.size > 0
    end

    def server_ready?(server)
      server_state(server)  == "operational"
    end

    def server_cloud_name(server)
      instance = instance_from_server(server)
      cloud = cloud_from_instance(instance)
      cloud.show.name
    end
    
    def server_info(server)
      server.show.current_instance.show(:view => 'extended')
    end

  private

    def server_state(server)
      instance_from_server(server).show.state
    end

    def instance_from_server(server)
      server_data = server.show
      if is_provisioned?(server)
        begin
          server_data.current_instance
        rescue
          server_data.next_instance
        end
      else
        server_data.next_instance
      end
    end

    def cloud_from_instance(instance)
      instance.show.cloud
    end
        
    def find_resource(api_resource, filter_key, filter_value)
      resource = nil
      list = list_resources(api_resource, filter_key, filter_value)
      raise "More than one #{api_resource} with the #{filter_key} of '#{filter_value}'. " + 
            "Please resolve via the RightScale dashboard and retry." if list.size > 1 
      resource = list.first unless list.empty?
      resource
    end
    
    def list_resources(api_resource, filter_key, filter_value)
      raise ArgumentError.new("api_resource must be a symbol") unless api_resource.kind_of?(Symbol)
      key = filter_key.to_s.delete("by_") # convert :by_name to "name"
      filter = {}
      filter = {:filter => ["#{key}==#{filter_value}"]} if filter_value
      list = @connection.send(api_resource).index(filter)
      list
    end
    
    def index_resource(api_resource, index_key, index_value)
      raise ArgumentError.new("api_resource must be a symbol") unless api_resource.kind_of?(Symbol)
      arry = @connection.send(api_resource).index(index_key => index_value)
      arry
    end
    
    def find_cloud_resource(cloud, api_resource, filter_key, filter_value)
      resource = nil
      list = list_subresources(cloud, api_resource, filter_key, filter_value)
      raise "More than one #{api_resource} with the #{filter_key} of '#{filter_value}'. " + 
            "Please resolve via the RightScale dashboard and retry." if list.size > 1 
      resource = list.first unless list.empty?
      resource
    end
    
    def list_subresources(api_resource, subresource, filter_key, filter_value)
      raise ArgumentError.new("subresource must be a symbol") unless subresource.kind_of?(Symbol)
      key = filter_key.to_s.delete("by_") # convert :by_name to "name"
      filter = {}
      filter = {:filter => ["#{key}==#{filter_value}"]} if filter_value
      list = api_resource.show.send(subresource).index(filter)
      list
    end

  end
end