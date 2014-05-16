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
    class RightscaleSecuritygroupList < Knife

      include Knife::RightscaleBase

      deps do
        require 'right_api_helper'
      end

      option :security_group_name,
        :short => "-n SECURITYGROUP_NAME",
        :long => "--name SECURITYGROUP_NAME",
        :description => "The partial name of the security group to search for",
        :proc => Proc.new { |i| Chef::Config[:knife][:security_group_name] = i }

      option :cloud_name,
        :short => "-C CLOUD_NAME",
        :long => "--cloud CLOUD_NAME",
        :description => "The partial name of the cloud to search for",
        :proc => Proc.new { |i| Chef::Config[:knife][:cloud_name] = i }

      banner "knife rightscale securitygroup list (options)"

      def run
        $stdout.sync = true

        validate!
        @clouds = connection.list_clouds(:by_name, config[:cloud_name])
        count = @clouds.size
        puts ui.color("Querying #{count} clouds for security groups.  Could take a minute...", :magenta) if count > 1
        security_group_list = [
          ui.color('Cloud', :bold),
          ui.color('Name', :bold),
          ui.color('Resource UID', :bold)
        ].flatten.compact

        output_column_count = security_group_list.length
        @clouds.each do |cloud|
          next unless connection.requires_security_groups?(cloud)
          @security_groups = connection.list_security_groups(cloud, :by_name, config[:security_group_name])
          @security_groups.each do |security_group|
            security_group_list << cloud.name
            security_group_list << security_group.name
            security_group_list << security_group.resource_uid
          end
        end
        puts ui.list(security_group_list, :uneven_columns_across, output_column_count)
      end

      private

      def validate!
        super([:rightscale_user, :rightscale_password, :rightscale_account_id])
      end

    end
  end
end
