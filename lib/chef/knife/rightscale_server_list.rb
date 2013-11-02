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
    class RightscaleServerList < Knife

      include Knife::RightscaleBase

      deps do
        require 'right_api_provision'
        require 'timeout'
      end

      banner "knife rightscale server list (options)"

      option :server_name,
        :short => "-n SERVERNAME",
        :long => "--name SERVERNAME",
        :description => "The name of the server to search for",
        :proc => Proc.new { |i| Chef::Config[:knife][:server_name] = i }

      def run
        $stdout.sync = true

        validate!
        
        @servers = connection.list_servers(:by_name, config[:server_name])
        
        server_list = [
          ui.color('Name', :bold),
          ui.color('Description', :bold),
          ui.color('State', :bold)
        ].flatten.compact
        
        output_column_count = server_list.length
        
        @servers.each do |server|
          server_list << server.name
          server_list << server.description
          server_list << server.state
        end
        
        puts ui.list(server_list, :uneven_columns_across, output_column_count)
        
      end
      
      private

      def validate!
        super([:rightscale_user, :rightscale_password, :rightscale_account_id])
      end
      
    end
  end
end
