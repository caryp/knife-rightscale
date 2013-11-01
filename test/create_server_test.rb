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

def run(knife_command)
  cmd = "bundle exec #{knife_command} --yes"
  puts "Command: #{cmd}"
  puts `#{cmd}`
  raise "ERROR: #{cmd} failed" unless $? == 0
end

describe "provision a ChefClient on each cloud" do

  [
    "EC2 us-west-2",
    "CS 2.2.14 Eng - XenServer",
    "Google",
    "HP Cloud",
    "Rackspace Open Cloud - Chicago"
  ].each do |cloud_name|

    it "can provision on '#{cloud_name}'" do

      run "knife rightscale server create --cloud '#{cloud_name}' " +
          "--server-template 291069003  --deployment 'KNIFE: test knife-provisioner' " +
          "--name 'KNIFE:ChefClient #{cloud_name}' " +
          "--no-block " +
          "--input 'chef/client/server_url':'text:https://api.opscode.com/organizations/kindsol' " +
          "--input 'chef/client/validation_name':'cred:CKP: validation_client_name' " +
          "--input 'chef/client/validator_pem':'cred:CKP:validator.pem' " +
          "--input 'chef/client/node_name':'text:MyChefClient' " +
          "--input 'chef/client/roles':'text:hello_world' "
    end
  end

    it "can delete server on '{cloud_name}'" do
      # wait for all servers (fail or pass)

      # -        begin
      # -          run "knife rightscale server delete 'KNIFE:ChefClient #{cloud_name}'"
      # -        ensure
      # -          run "knife client delete MyChefClient"
      # -          run "knife node delete MyChefClient"
      # -        end
    end

end


