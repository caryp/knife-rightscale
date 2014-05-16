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

# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'knife-rightscale/version'

Gem::Specification.new do |gem|
  gem.name          = "knife-rightscale"
  gem.version       = Knife::Rightscale::VERSION
  gem.authors       = ["Cary Penniman"]
  gem.email         = ["cary@rightscale.com"]
  gem.description   = %q{One plugin to provision them all!  This plugin allows the Chef developer to provision Chef clients on all major clouds using the RightScale platform.}
  gem.summary       = %q{RightScale plugin for Knife}
  gem.homepage      = "http://github.com/caryp/knife-rightscale"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.add_dependency "right_api_helper", ">= 1.1.2"
  gem.add_dependency "rake"
  gem.add_dependency "yard"
  gem.add_dependency "rspec"
  gem.add_dependency "chef"

  gem.require_paths = ["lib"]
end
