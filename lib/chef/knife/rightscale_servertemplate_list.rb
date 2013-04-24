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
    class RightscaleServertemplateList < Knife

      include Knife::RightscaleBase

      deps do
        require 'right_api_client'
      end
      
      option :server_template_name,
        :short => "-n SERVERTEMPLATE_NAME",
        :long => "--name SERVERTEMPLATE_NAME",
        :description => "The partial name of the ServerTemplate to search for",
        :proc => Proc.new { |i| Chef::Config[:knife][:server_template_name] = i }

      banner "knife rightscale servertemplate list (options)"

      def run
        $stdout.sync = true

        validate!
        
        @servertemplates = connection.list_servertemplates(:by_name, config[:server_template_name])

        servertemplate_list = [
          ui.color('Name', :bold),
          ui.color('Revision', :bold),
          ui.color('ID', :bold)
        ].flatten.compact
        
        output_column_count = servertemplate_list.length
        
        @servertemplates.each do |servertemplate|
          revision = servertemplate.revision.to_s 
          servertemplate_list << servertemplate.name
          servertemplate_list << ((revision == "0") ? "HEAD" : revision)
          servertemplate_list << servertemplate.href.to_s.delete("/api/server_templates/")
        end
        
        puts ui.list(servertemplate_list, :uneven_columns_across, output_column_count)

      end
      
      private

      def validate!
        super([:rightscale_user, :rightscale_password, :rightscale_account_id])
      end
      
    end
  end
end
