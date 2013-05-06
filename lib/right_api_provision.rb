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
  
  module InputType
    TEXT = "txt"
    ENV = "env"
    CRED = "cred"
    KEY = "key"
    IGNORE = "ignore"
    ARRAY = "array"
  end
  
  class Input
    
    attr_reader :name, :type, :value
    
    # Create a new input
    #
    # @param name [String] the name of the input
    # @param type [String]
    def initialize(name, type, value)
    end  
    
  end
end


module RightApiProvision
  module DTO 

    class Base
      attr_accessor :id, :name
    end

    class Cloud < Base
      attr_accessor :description
    end
  
    class Deployment < Base
      attr_accessor :description
    end
  
    class MultiCloudImage < Base
    end

    class CloudSetting < Base
      attr_accessor :default_flavor
    end    
  
    class SecurityGroup < Base
      attr_accessor :resource_uid
    end
  
    # Information about a server
    #
    # This object is returned by the {Provisioner#info} method.
    #
    # @!attribute [rw] public_ip 
    #   @return [String] the server's public IPV4 address
    # @!attribute [rw] private_ip 
    #   @return [String] the server's private IPV4 address
    # @!attribute [rw] public_dns 
    #   @return [String] the server's public FQDN
    # @!attribute [rw] private_dns 
    #   @return [String] the server's private FQDN
    #
    class Server < Base
      attr_accessor :description
      attr_accessor :state
      attr_accessor :public_ip, :private_ip
      attr_accessor :public_dns, :private_dns
    end

    class ServerTemplate < Base
      attr_accessor :revision
    end
  end

end


module RightApiProvision
  
  
  #
  # This is the main class to use to create a server on the RightScale platform.
  # Use the {#provision} method to create and launch 
  # the server.  
  #
  # The other methods are for checking server state and gathering information
  # once the server is operational.
  #
  class Provisioner
    
    RETRY_DELAY = 10 # seconds
    
    def initialize(email, password, account_id, api_url = nil)
    end
    
    # @return [Array] an array of {DTO::Cloud} objects
    def list_clouds(name)
    end
  
    # @return [Array] an array of {DTO::Deployment} objects
    def list_deployments(name)
    end
  
    # @return [Array] an array of {DTO::MultiCloudImage} objects
    # @TODO: can we speed things up with filtering by cloud id?
    def list_multi_cloud_images(name)
    end  

    # @return [Array] an array of {DTO::CloudSetting} objects
    def list_cloudsettings(mci_id)
    end
  
    # @return [Array] an array of {DTO::SecurityGroup} objects
    def list_security_groups(cloud_id, name)
    end

    # @return [Array] an array of {DTO::Server} objects
    def list_servers(name)
    end

    # @return [Array] an array of {DTO::ServerTemplate} objects
    def list_server_templates(name)
    end

    # @return [TrueFalse] true if the server was succesfully deleted
    def delete_server(name)
    end

    # Provision a server using RightScale
    #
    # @param server_name [String] the name to give the server that will be
    #        created.
    # @param server_template [String] the name or ID of the ServerTemplate to 
    #        create the server from.
    # @param cloud_name [String] name of cloud to provision on.
    # @param deployment_name [String] name of deployment to add the server to. 
    #        This will be created if it does not exist.
    # @param inputs [Array] An array of {Input} objects.
    # @param ssh_key_id [String] The resource_uuid of an ssh key from the 
    #        RightScale dashboard. Only required on EC2 and Eucalyptus.
    # @param secgroup_id [Array] An array of security group IDs to place the 
    #        server in.
    #
    # @raise {RightApiProvisionException} if anything 
    #         goes wrong
    def provision(
      server_name, 
      server_template, 
      cloud_name, 
      deployment_name, 
      inputs,
      ssh_key_id,
      secgroup_id)
    end
    
    
    # Register a custom progress indicator
    #
    # @example
    #   do
    #     @TODO: add an example
    #   end
    # @param progress_block [Block] block to execute before each loop iteration.
    # @yield [Logger] A Logger object will be passed as a parameter into 
    #        your block.
    def register_progress_indicator(&progress_block)
      @progress_indicator = progress_block
    end

    # Check to see if the server is fully configured
    #
    # @return [TrueFalse] if the server operational
    def operational?
    end

    # Wait for the server to be ready
    #
    # Blocks execution until the server state is operational
    # Use pending_block param to provide custom progress UI output.
    #
    # @param delay[Integer] seconds to sleep between polling attempts
    # @param pending_block[Block] block to execute before each attempt.
    #
    # @raise RightApiProvisionExceptionUNEXPECTED_STATE if invalid server 
    #         state is received.
    def wait_for_operational(delay, &pending_block)
    end

    # Get server information
    #
    # Grabs information from an operational server.
    # This will poll until the information is available from the cloud.
    #
    # @param delay[Integer] seconds to sleep between polling attempts
    # 
    # @return [DTO::Server] initialized {DTO::Server} object
    def info(delay)
    end
        
  end
end






