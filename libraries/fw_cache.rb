# frozen_string_literal: true

# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'gcp_base_cache'

# Cache for VPC Firewalls.
#
class FirewallCache < GCPBaseCache
  name 'FirewallCache'
  desc 'The Firewall Cache stores a list of firewall names and their corresponding
  google_compute_firewall objects in a hashmap

  Usage:
  fw_cache = FirewallCache(project: "project_name")

  fw_cache.firewall_names
  <prints list of firewall names>

  fw_cache.firewall_objects["fw_name"]
  <returns google_compute_firewall(project: "project_name", name: fw_name)>
  '

  @@cached_firewall_names = []
  @@cached_firewall_objects = {}
  @@firewall_names_cache_set = false
  @@firewall_objects_cache_set = false

  def initialize(params = {})
    super(params) # Pass all parameters to the parent class
    @gcp_project_id = params[:project] # Extract the project from the params hash
  end

  def firewall_names
    set_firewall_names_cache unless firewall_names_cache_set?
    @@cached_firewall_names
  end

  def firewall_objects
    set_firewall_objects_cache unless firewall_objects_cache_set?
    @@cached_firewall_objects
  end

  def firewall_names_cache_set?
    @@firewall_names_cache_set
  end

  def firewall_objects_cache_set?
    @@firewall_objects_cache_set
  end

  private

  def set_firewall_names_cache
    @@cached_firewall_names =
      inspec.google_compute_firewalls(project: @gcp_project_id)
            .firewall_names
    @@firewall_names_cache_set = true
  end

  def set_firewall_objects_cache
    @@cached_firewall_objects = {}

    firewall_names.each do |firewall_name|
      @@cached_firewall_objects[firewall_name] =
        inspec.google_compute_firewall(project: @gcp_project_id,
                                       name: firewall_name)
    end
    @@firewall_objects_cache_set = true
  end
end
