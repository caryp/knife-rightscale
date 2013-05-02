# Knife RightScale

This is a Knife plugin for RightScale. This plugin gives knife the ability to 
provision servers on clouds managed by the RightScale platform.  It is expected 
that you already have a Chef Server running or are using a hosted Chef solution 
from OpsCode.

NOTE: this plugin is currently under development and subject to change

## REQUIREMENTS:

You will need a RightScale account with at least one cloud registered.  You can 
sign up for a free trial account [here](https://www.rightscale.com).  

I was lazy and only added support for the RightScale API 1.5 (since API 1.0 is 
EC2 only and deprecated).  As such, this plugin cannot currently provision 
servers on EC2. If you need this capability and would like to part in a private 
beta to enable that functionality, please contact support@rightscale.com and 
they will hook you up.  If you have any problems, please send me an email 
directly.

You will also need a running Chef Server.  If you don't already have one you can
sign up for a free trial of Hosted Chef from Opscode [here](http://www.opscode.com/hosted-chef/).


## INSTALLATION:

Be sure you are running the latest version Chef 10. Versions earlier than 0.10.0
don't support plugins.  This has not yet been tested with Chef 11.

    gem install chef -v 10.24.0

This plugin is distributed as a Ruby Gem. To install it, run:

    gem install knife-rightscale

Depending on your system's configuration, you may need to run this command with 
root privileges.

## CONFIGURATION:

In order to communicate with the RightScale API you will have to tell Knife 
about your RightScale account information.  The easiest way to accomplish this 
is to create some entries in your <tt>knife.rb</tt> file:

    knife[:rightscale_user]  = "you@yourdomain.com"
    knife[:rightscale_password] = "supersecretpassword"
    knife[:rightscale_account_id] = "1234"

If your knife.rb file will be checked into a SCM system (ie readable by others) 
you may want to read the values from environment variables:

    knife[:rightscale_user] = "#{ENV['RIGHTSCALE_EMAIL']}"
    knife[:rightscale_password] = "#{ENV['RIGHTSCALE_PASSWORD']}"

You also have the option of passing your RightScale credentials into the 
individual knife subcommands using the <tt>-A</tt> (or <tt>--rightscale-account-id</tt>), 
<tt>-U</tt> (or <tt>--rightscale-user</tt>), <tt>-P</tt> (or <tt>--rightscale-password</tt>) command options

## Provision a Server

### List Clouds
This will list all the registered clouds available in your RightScale account:

    knife rightscale cloud list

to filter by partial name match use ```-n``` or ```--name``` option

    knife rightscale cloud list --name rackspace

### List ServerTemplates
List the ServerTemplates available in your account.  Typically you will just want to find a Chef Client template.  For example:

    knife rightscale servertemplate list --name "Chef Client"
    
### Launch a server
To provision a new server, supply ServerTemplate choice and target cloud as options:

    knife rightscale server create \
      --cloud "Rackspace Open Cloud - Chicago" \
      --server-template "Chef Client (v13.4)" \
      --deployment "CKP: My Sandbox" \
      --name "CKP:ChefClient" \
      --input "chef/client/server_url":"text:https://api.opscode.com/organizations/kindsol" \
      --input "chef/client/validation_name":"cred:CKP: validation_client_name" \
      --input "chef/client/validator_pem":"cred:CKP:validator.pem" \
      --input "chef/client/node_name":"text:MyChefClient" \
      --input "chef/client/roles":"text:hello_world"

The server with a name specified by the ```--name``` option will be created in the specified ```--deployment```.  If the deployment is not found, it will be created.  You can supply ServerTemplate inputs values using the ```--input``` option, which can be specified multiple times as shown.

The ```--server-template``` option can pass either an name or ID.

For a list of all possible options run:

    knife rightscale server create --help

### Delete Server
Once done with the server, you can terminate and delete it using:

    knife rightscale server delete SERVER_NAME

use the ```--yes``` option to bypass confirmation.


## OTHER SUBCOMMANDS:

Some other subcommands that can be useful for provisioning servers are listed 
below.  These are intended to query possible options that you can pass to the 
server create command. 

All supported command options can be found by invoking:

    knife rightscale --help 

Specific details for each command can be found by passing the ```--help``` 
option the the subcommand.  For example:

    knife rightscale <subcommand> --help


### List Images
List the supported images for a given ServerTemplate and target cloud

    knife rightscale image list \
      --server-template "Chef Client (v13.4)" \
      --cloud "Rackspace Open Cloud - Chicago"

This will also indicate the default Instance Type or flavor for each image.


### List Deployments
To list all the deployments available in your RightScale account:

    knife rightscale deployment list

to filter by partial name match use the ```--name``` option


### List Security Groups
To list all the Security Groups available per cloud:

    knife rightscale securitygroup list

to filter by partial name match use the ```--name``` option or narrow the 
results using the ```--cloud``` option


### List Servers
To list all the servers in your RightScale account:

    knife rightscale server list

to filter by partial name match use the ```--name``` option


## FUTURE FEATURES
 * create action
   * ability to select image other than the default image on ServerTemplate
   * ability to select instance type other than default (needed for cloudstack)
 * add support for instance type aka "flavor" (list and for server create)
 * add support for datacents/zone type (list and for server create)
 ** Private beta
 * display audit entry when server strands
 * ability to add server tags on create
 * server array create action 
 * add timeout for operational 
 * credentials list action (waiting for new API release)
 * add VPC support to create action
 

## LICENSE:

Author:: Cary Penniman (<cary@rightscale.com>)
Copyright:: Copyright (c) 2013 RightScale, Inc.
License:: Apache License, Version 2.0
See attribution notice in README.md

This readme is modified from the knife-ec2 plugin project code 
That project is located at https://github.com/opscode/knife-ec2
Author:: Adam Jacob (<adam@opscode.com>)
Copyright:: Copyright (c) 2009-2011 Opscode, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
