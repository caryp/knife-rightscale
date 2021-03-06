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

require 'chef/knife/rightscale_base'

class Chef
  class Knife
    class RightscaleDeploymentList < Knife

      include Knife::RightscaleBase

      deps do
        require 'right_api_helper'
      end
      
      option :deployment_name,
        :short => "-n DEPLOYMENTNAME",
        :long => "--name DEPLOYMENTNAME",
        :description => "The name of the deployment to search for",
        :proc => Proc.new { |i| Chef::Config[:knife][:deployment_name] = i }

      banner "knife rightscale deployment list (options)"

      def run
        $stdout.sync = true

        validate!
        
        @deployments = connection.list_deployments(:by_name, config[:deployment_name])

        deployment_list = [
          ui.color('Name', :bold),
          ui.color('Description', :bold)
        ].flatten.compact
        
        output_column_count = deployment_list.length
        
        @deployments.each do |deployment|
          deployment_list << deployment.name
          deployment_list << deployment.description
        end
        
        puts ui.list(deployment_list, :uneven_columns_across, output_column_count)

      end
      
      private

      def validate!
        super([:rightscale_user, :rightscale_password, :rightscale_account_id])
      end
      
    end
  end
end
