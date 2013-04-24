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

require "right_api_provision/api15"
 
describe "API15 object" do

  before(:each) do
    @api = RightApiProvision::API15.new()
    apiStub = double("RightApi::Client")
    RightApi::Client.should_receive(:new).and_return(apiStub)
    @conn = @api.connection("someemail", "somepasswd", "someaccountid", "https://my.rightscale.com")
  end
  
  describe "requires_ssh_keys?" do
    it "should return true when cloud supports ssh keys" do
      sshKeyStub = stub("sshkeys", :index => ["key1", "key2"])
    
      cStub = stub("cloud", :ssh_keys => sshKeyStub)
      csStub = stub("clouds", :show => cStub)
    
      @api.requires_ssh_keys?(csStub).should == true
    end
  
    it "should return false when cloud doesn't support ssh keys" do
      cStub = stub("cloud", :ssh_keys => "will throw exception if no ssh keys")
      cStub.should_receive(:ssh_keys).and_raise(RightApi::Exceptions::ApiException.new "error")
      csStub = stub("clouds", :show => cStub)
    
      @api.requires_ssh_keys?(csStub).should == false
    end
  end

  describe "find_ssh_key_by_uuid_or_first" do
    it "should find first ssh_key" do
      sshKeyStub = stub("sshkeys", :index => ["key1", "key2"])
    
      cStub = stub("cloud", :ssh_keys => sshKeyStub)
      csStub = stub("clouds", :show => cStub)
    
      @api.find_ssh_key_by_uuid_or_first(csStub).should == "key1"
    end
  end  
  
  it "should find deployment by name" do
    deploymentsStub = stub("deployments", :index => [ :name => "my_fake_deployment" ])
    @api.instance_variable_get("@connection").should_receive(:deployments).and_return(deploymentsStub)
    @api.find_deployment_by_name("my_fake_deployment")
  end
  
  it "should raise error if deployment not found by name" do
    deploymentsStub = stub("deployments", :index => nil)
    @api.instance_variable_get("@connection").should_receive(:deployments).and_return(deploymentsStub)
    lambda{@api.find_deployment_by_name("my_fake_deployment")}.should raise_error
  end
  
  it "should raise error if multiple deployments found by name" do
    deploymentsStub = stub("deployments", :index => [ {:name => "my_fake_deployment"}, {:name => "my_fake_deployment2"} ])
    @api.instance_variable_get("@connection").should_receive(:deployments).and_return(deploymentsStub)
    lambda{@api.find_deployment_by_name("my_fake_deployment")}.should raise_error
  end
  
  it "should find server by name" do
    serversStub = stub("servers", :index => [ :name => "my_fake_server" ])
    @api.instance_variable_get("@connection").should_receive(:servers).and_return(serversStub)
    @api.find_server_by_name("my_fake_server")
  end
  
  it "should raise error if multiple servers found by name" do
    serversStub = stub("servers", :index => [ {:name => "my_fake_server"}, {:name => "my_fake_server2"} ])
    @api.instance_variable_get("@connection").should_receive(:servers).and_return(serversStub)
    lambda{@api.find_server_by_name("my_fake_server")}.should raise_error
  end
  
  it "should find MCI by name" do
    pending ("TODO: add support for multi_cloud_image_name")
    mcisStub = stub("mcis", :index => [ :name => "my_fake_mci" ])
    @api.instance_variable_get("@connection").should_receive(:mcis).and_return(mcisStub)
    @api.find_mci_by_name("my_fake_mci")
  end
  
  it "should raise error if multiple MCI found by name" do
    pending ("TODO: add support for multi_cloud_image_name")
    mcisStub = stub("mcis", :index => [ {:name => "my_fake_mci"}, {:name => "my_fake_mci2"} ])
    @api.instance_variable_get("@connection").should_receive(:mcis).and_return(mcisStub)
    lambda{@api.find_mci_by_name("my_fake_mci")}.should raise_error
  end
  
  it "should find servertemplate by name" do
    servertemplatesStub = stub("servertemplates", :index => [ stub("servertemplate", :name => "my_fake_servertemplate", :revision => true) ])
    @api.instance_variable_get("@connection").should_receive(:server_templates).and_return(servertemplatesStub)
    @api.find_servertemplate("my_fake_servertemplate")
  end

  it "should raise error if multiple servertemplates found by name" do
    servertemplatesStub = stub("servertemplates", :index => [ stub("servertemplate", :name => "my_fake_servertemplate"), stub("servertemplate", :name => "my_fake_servertemplate") ])
    @api.instance_variable_get("@connection").should_receive(:server_templates).and_return(servertemplatesStub)
    lambda{@api.find_servertemplate("my_fake_servertemplate")}.should raise_error
  end

  it "should find servertemplate by id" do
    servertemplatesStub = stub("servertemplates", :index => [ :name => "my_fake_servertemplate" ])
    @api.instance_variable_get("@connection").should_receive(:server_templates).and_return(servertemplatesStub)
    @api.find_servertemplate(1234)
  end

  it "should create deployment" do
    deploymentsStub = stub("deployments", :create => [ {:name => "my_fake_deployment"} ])
    @api.instance_variable_get("@connection").should_receive(:deployments).and_return(deploymentsStub)
    deploymentsStub.should_receive(:create)
    @api.create_deployment("my_deployment")
  end

  it "should create server" do
    dStub = stub("deployment", :href => "/some/fake/path")
    dsStub = stub("deployments", :show => dStub)
    @api.should_receive(:create_deployment).and_return(dsStub)
    deployment = @api.create_deployment("my_deployment")

    stStub = stub("servertemplate", :href => "/some/fake/path", :show => "")
    stsStub = stub("servertemplates", :show => stStub)
    @api.should_receive(:find_servertemplate).and_return(stsStub)
    server_template = @api.find_servertemplate(1234)
    
    cStub = stub("cloud", :href => "/some/fake/path")
    csStub = stub("clouds", :show => cStub)
    @api.should_receive(:find_cloud_by_name).and_return(csStub)
    cloud = @api.find_cloud_by_name(1234)
    
    serversStub = stub("servers", :create => [ :name => "my_fake_server" ])
    @api.instance_variable_get("@connection").should_receive(:servers).and_return(serversStub)
    @api.create_server(deployment, server_template, nil, cloud, "my_fake_server", nil)
  end  

  it "should launch server with inputs" do
    serverStub = stub("server", :name => "foo")
    serversStub = stub("servers", :launch => true, :show => serverStub, :index => [ :name => "my_fake_server" ])
    @api.should_receive(:create_server).and_return(serversStub)
    server = @api.create_server("foo", "bar", "my_fake_server")
    @api.instance_variable_get("@connection").should_receive(:servers).and_return(serversStub)    
    @api.launch_server(server, [ {:name => "input1", :value => 1} ])
  end  

  it "should launch server without inputs" do
    serverStub = stub("server", :name => "foo")
    serversStub = stub("servers", :launch => true, :show => serverStub, :index => [ :name => "my_fake_server" ])
    @api.should_receive(:create_server).and_return(serversStub)
    server = @api.create_server("foo", "bar", "my_fake_server")    
    @api.instance_variable_get("@connection").should_receive(:servers).and_return(serversStub)   
    @api.launch_server(server)
  end  

  it "returns data_request_url for instance" do
    @user_data = "RS_rn_url=amqp://b915586461:278a854748@orange2-broker.test.rightscale.com/right_net&RS_rn_id=4985249009&RS_server=orange2-moo.test.rightscale.com&RS_rn_auth=d98106775832c174ffd55bd7b7cb175077574adf&RS_token=b233a57d1d24f27bd8650d0f9b6bfd54&RS_sketchy=sketchy1-145.rightscale.com&RS_rn_host=:0"
    @request_data_url = "https://my.rightscale.com/servers/data_injection_payload/d98106775832c174ffd55bd7b7cb175077574adf"

    @api.data_request_url(@user_data).should == @request_data_url
  end
  
  pending "waits for state to change from booting state" do
    currentStub = stub("instance", :state => "booting")
    instanceStub = stub("instance", :show => currentStub)
    serverStub = stub("server", :api_methods => [:current_instance], :current_instance => instanceStub)
    serversStub = stub("servers", :launch => true, :show => serverStub, :index => [ :name => "my_fake_server" ])
    
    @api.server_wait_for_state(@server, "booting", 1)
  end
    
  it "fails if the server's cloud is not the requested cloud" do
    pending "TODO"
  end
  
  it "sets inputs on the next instance" do
    pending "TODO"
  end
  
  it "terminates a server" do
    pending "TODO"
    serverStub = stub("server", :name => "foo")
    # serversStub = stub("servers", :launch => true, :show => serverStub, :index => [ :name => "my_fake_server" ])
    # @api.should_receive(:create_server).and_return(serversStub)
    # server = @api.create_server("foo", "bar", "my_fake_server")    
    # @api.instance_variable_get("@connection").should_receive(:servers).and_return(serversStub)   
    @api.terminate_server(serverStub)
  end
    
  
end
