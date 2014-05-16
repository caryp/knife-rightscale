#
# Author:: Cary Penniman (<cary@rightscale.com>)
# Copyright:: Copyright (c) 2013 RightScale, Inc.
# License:: Apache License, Version 2.0
#
# This file is modified from the knife-ec2 plugin project code
# That project is located at https://github.com/opscode/knife-ec2
# Author:: Seth Chisamore <schisamo@opscode.com>
# Copyright:: Copyright (c) 2011 Opscode, Inc.
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
require 'chef/knife'
require 'right_api_helper'

class Chef
  class Knife
    module RightscaleBase

      # :nodoc:
      # Would prefer to do this in a rational way, but can't be done b/c of
      # Mixlib::CLI's design :(
      def self.included(includer)
        includer.class_eval do

          deps do
            require 'right_api_helper'
          end

          option :rightscale_user,
            :short => "-U USER",
            :long => "--rightscale-user USER",
            :description => "Your RightScale User Email",
            :proc => Proc.new { |key| Chef::Config[:knife][:rightscale_user] = key }

          option :rightscale_password,
            :short => "-P PASSWORD",
            :long => "--rightscale-password PASSWORD",
            :description => "Your RightScale password",
            :proc => Proc.new { |key| Chef::Config[:knife][:rightscale_password] = key }

          option :rightscale_account_id,
            :short => "-A ID",
            :long => "--rightscale-account-id ID",
            :description => "Your RightScale account ID",
            :proc => Proc.new { |key| Chef::Config[:knife][:rightscale_account_id] = key }

          option :rightscale_api_url,
            :short => "-L API_URL",
            :long => "--rightscale-api-url API_URL",
            :description => "The API URL (defaults to my.rightscale.com)",
            :default => "https://my.rightscale.com",
            :proc => Proc.new { |key| Chef::Config[:knife][:rightscale_api_url] = key }

        end
      end

      def connection
        @connection ||= begin
          api_shim = RightApiHelper::API15.new(right_api_client)
          set_log_level(api_shim)
          api_shim
        end
      end

      def right_api_client
        @right_api_client ||= begin
          session = RightApiHelper::Session.new
          set_log_level(session)
          right_api_client = session.create_client(
              Chef::Config[:knife][:rightscale_user],
              Chef::Config[:knife][:rightscale_password],
              Chef::Config[:knife][:rightscale_account_id],
              Chef::Config[:knife][:rightscale_api_url]
            )
          right_api_client
        end
      end

      def set_log_level(obj)
        log_level = (config[:verbosity] >= 1) ? Logger::DEBUG : Logger::INFO
        obj.log_level(log_level)
      end

      def locate_config_value(key)
        key = key.to_sym
        config[key] || Chef::Config[:knife][key]
      end

      def msg_pair(label, value, color=:cyan)
        if value && !value.to_s.empty?
          puts "#{ui.color(label, color)}: #{value}"
        end
      end

      def validate!(keys=[:rightscale_user, :rightscale_password, :rightscale_account_id])
        errors = []

        keys.each do |k|
          pretty_key = k.to_s.gsub(/_/, ' ').gsub(/\w+/){ |w| (w =~ /(ssh)|(aws)/i) ? w.upcase  : w.capitalize }
          if Chef::Config[:knife][k].nil? && config[k].nil?
            errors << "You did not provide a valid '#{pretty_key}' value."
          end
        end

        if errors.each{|e| ui.error(e)}.any?
          exit 1
        end
      end

    end
  end
end


