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
    class RightscaleServerDelete < Knife

      include Knife::RightscaleBase

      banner "knife rightscale server delete SERVER"

      def run
        validate!
        
        @server_name = @name_args[0]
        
        if @server_name.nil?
          show_usage
          ui.fatal("You must specify a server name")
          exit 1
        end

        confirm("Do you really want to delete #{@server_name}")
        connection.delete_server(@server_name)
      end
      
      private

      def validate!
        super([:rightscale_user, :rightscale_password, :rightscale_account_id])
      end
      
    end
  end
end
