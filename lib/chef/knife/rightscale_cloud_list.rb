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
    class RightscaleCloudList < Knife

      include Knife::RightscaleBase

      deps do
        require 'right_api_helper'
        require 'timeout'
      end

      banner "knife rightscale cloud list (options)"
      
      option :cloud_name,
        :short => "-n CLOUD_NAME",
        :long => "--name CLOUD_NAME",
        :description => "The name of the cloud to search for",
        :proc => Proc.new { |i| Chef::Config[:knife][:cloud_name] = i }

      def run
        $stdout.sync = true

        validate!
        
        # query clouds
        @clouds = connection.list_clouds(:by_name, config[:cloud_name])

        cloud_list = [
          ui.color('Name', :bold),
          ui.color('Description', :bold)
        ].flatten.compact
        
        output_column_count = cloud_list.length
        
        @clouds.each do |cloud|
          cloud_list << cloud.name
          cloud_list << cloud.description
        end
        
        puts ui.list(cloud_list, :uneven_columns_across, output_column_count)

      end
      
      private

      def validate!
        super([:rightscale_user, :rightscale_password, :rightscale_account_id])
      end
      
    end
  end
end
