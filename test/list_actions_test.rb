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

def run_list_command(resource_name, options = "")
  cmd = "bundle exec knife rightscale #{resource_name} list #{options}"
  puts `#{cmd}`
  raise "ERROR: #{cmd} failed" unless $? == 0
end

describe "run list actions" do

  it "lists security groups" do
    run_list_command("securitygroup")
  end
  
  it "lists clouds" do
    run_list_command("cloud")
  end
  
  it "lists deployments" do
    run_list_command("deployment")
  end
  
  it "lists servers" do
    run_list_command("server")
  end
  
  it "lists servertemplate" do
    run_list_command("servertemplate")
  end
  
  it "lists images" do
    run_list_command("image", "-s 292810003 --cloud 'EC2 us-west-2'")
  end
  
end
