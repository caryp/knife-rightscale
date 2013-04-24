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

# returns dto object
list_clouds(name) => id, name, description
list_deployemnt(name) => id, name, description
list_mci(st_id, name) => id, name
list_mci_cs(mci_id) => id, name, default_instance_type # can we filter by cloud id?
list_secgroups(cloud_id, name) => id, name, resource_uid

# returns object_id
find_cloud(name) => id
find_st(name) => id


#
# Provisioner Object
#

# Provision a server using RightScale
#
# @param name [String] the name to give the server that will be created.
# @param servertemplate [String] the name or ID of the ServerTemplate to create the server from.
# @param cloud [String] name of cloud to provision on.
# @param deployment [String] name of deployment to add server to. 
#        This will be created if it does not exist.
# @param 
# @param delay[Integer] seconds to sleep between polling attempts
# @param pending_block[Block] block to execute before each attempt.
#
# @returns [Object] a provisioner object for the created server
#
# @raises RightApiProvisionException if anything goes wrong
provision(
  name, 
  st_name, 
  cloud_name, 
  deploy_name, 
  inputs,
  ssh_key_uid,
  secgroup_id,
  &pending_block)

# Check to see if the server is ready
#
# @returns true[TrueFalse] if the server operational
server_operational?

# Wait for the server to be ready
#
# Blocks execution until the server state is operational
# Use pending_block param to provide custom progress UI output.
#
# @param delay[Integer] seconds to sleep between polling attempts
# @param pending_block[Block] block to execute before each attempt.
#
# @raises RightApiProvisionExceptionUNEXPECTED_STATE if invalid server 
#         state is received.
wait_for_operational(delay, &pending_block)

# Get server information
#
# Grabs the DNS and IP information from an operational server.
# This will poll until the information is available from the cloud.
# Use pending_block param to provide custom progress UI output.
#
# @param delay[Integer] seconds to sleep between polling attempts
# @param pending_block[Block] block to execute before each attempt. 
# 
# @returns 
server_info(delay, &pending_block)






