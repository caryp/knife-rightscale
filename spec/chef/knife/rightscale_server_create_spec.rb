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

require File.expand_path('../../../spec_helper', __FILE__)

Chef::Knife::RightscaleServerCreate.load_deps

describe Chef::Knife::RightscaleServerCreate do
  before(:each) do
    Chef::Config[:node_name]  = "webmonkey.example.com"
    @knife = Chef::Knife::RightscaleServerCreate.new
    @stdout = StringIO.new
    @knife.stub(:stdout).and_return(@stdout)
    provisionerStub = double("provisioner")
    provisionerStub.stub(:provision)
    @knife.stub(:get_rightscale_provisioner).and_return(provisionerStub)
  end

  it "provisions server" do
    @knife.config = {
      :server_template => "my servertemplate",
      :deployment_name => 'my deployment',
      :server_name => 'my server',
      :cloud_name => "my favorite cloud",
      :rightscale_user => "someuser",
      :rightscale_password => "somepassword",
      :rightscale_account_id => "1234"
    }
    @knife.run
  end


end