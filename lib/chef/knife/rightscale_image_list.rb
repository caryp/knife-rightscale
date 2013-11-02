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
    class RightscaleImageList < Knife

      include Knife::RightscaleBase

      deps do
        require 'right_api_provision'
      end

      option :server_template,
        :short => "-s SERVER_TEMPLATE",
        :long => "--server-template SERVER_TEMPLATE",
        :description => "The name of the ServerTemplate or ID to use for the server",
        :proc => Proc.new { |i| Chef::Config[:knife][:server_template] = i },
        :required => true
        
      option :cloud_name,
        :short => "-c CLOUD",
        :long => "--cloud CLOUD",
        :description => "The cloud you plan to run on.",
        :proc => Proc.new { |f| Chef::Config[:knife][:cloud_name] = f },
        :required => true

      option :image_name,
        :short => "-n IMAGE_NAME",
        :long => "--name IMAGE_NAME",
        :description => "The partial name of the image to search for",
        :proc => Proc.new { |i| Chef::Config[:knife][:image_name] = i }

      banner "knife rightscale image list (options)"

      def run
        $stdout.sync = true

        validate!
        
        # fail if the requested cloud is not registered with RightScale account
        puts(ui.color('Looking up cloud...', :magenta)) 
        @cloud = connection.find_cloud_by_name(config[:cloud_name])
        raise "ERROR: cannot find a cloud named: '#{config[:cloud_name]}'. " +
              "See 'knife rightscale cloud list' command for a list of clouds" +
              " registered with your RightScale account" unless  @cloud

        puts(ui.color('Looking up ServerTemplate...', :magenta)) 
        @st = connection.find_servertemplate(config[:server_template])
        raise "ERROR: cannot find ServerTemplate '#{config[:server_template]}'. Did you import it?\n" + 
              "Visit http://bit.ly/VnOiA7 for more info.\n\n" unless  @st

        image_list = [
          ui.color('Image', :bold),
          ui.color('Instance Type (default)', :bold)
        ].flatten.compact
      
        output_column_count = image_list.length
        
        puts(ui.color('Looking up supported multi-cloud images...', :magenta)) 
        @multi_cloud_images = connection.list_multi_cloud_images(@st, :by_name, config[:image_name])

        print(ui.color('Inspecting ServerTemplate images...', :magenta)) 
        @multi_cloud_images.each do |multi_cloud_image|
          multi_cloud_image.settings.index.each do |cloud_setting|
            print(ui.color(".", :magenta)) 
            STDOUT.flush
            next unless registered_cloud?(cloud_setting.cloud)
            image_list << multi_cloud_image.name
            image_list << instance_type(cloud_setting.show)
          end
        end
        puts
        puts ui.list(image_list, :uneven_columns_across, output_column_count)
      end
      
      private
      
      def instance_type(setting)
        type = "n/a"
        type = setting.instance_type.show.name if instance_type?(setting)
        type
      end
      
      def instance_type?(setting)
        setting.respond_to?(:instance_type)
      end
      
      def registered_cloud?(cloud)
        cloud.href == @cloud.href
      end

      def validate!
        super([:rightscale_user, :rightscale_password, :rightscale_account_id])
      end
      
    end
  end
end
