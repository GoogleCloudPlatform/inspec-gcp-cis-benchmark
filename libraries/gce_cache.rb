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

# Cache for GCE instances
#
class GCECache < GCPBaseCache
  name 'GCECache'
  desc 'The GCE cache resource contains functions consumed by the CIS/PCI
       Google profiles:
       https://github.com/GoogleCloudPlatform/inspec-gcp-cis-benchmark'
  attr_reader :gce_zones

  @@cached_gce_instances = []
  @@gce_instances_cached = false

  def initialize(params = {})
    super(params) # Pass all parameters to the parent class (GCPBaseCache)
    # @gcp_project_id is now set by the superclass from params[:project]

    # Extract gce_zones from params and handle default
    @gce_zones = if params[:gce_zones] && !params[:gce_zones].empty?
                   params[:gce_zones]
                 else
                   # Since @gcp_project_id is set by super(params), we can use it here.
                   inspec.google_compute_zones(project: @gcp_project_id).zone_names
                 end
  end

  def gce_instances_cache
    set_gce_instances_cache unless gce_cached?
    @@cached_gce_instances
  end

  def gce_cached?
    @@gce_instances_cached
  end

  def set_gce_instances_cache
    @@cached_gce_instances = []
    # Loop/fetch/cache the names and locations of GKE clusters
    @gce_zones.each do |gce_zone|
      inspec.google_compute_instances(project: @gcp_project_id, zone: gce_zone)
            .instance_names.each do |instance|
        @@cached_gce_instances.push({ name: instance, zone: gce_zone })
      end
    end
    # Mark the cache as full
    @@gce_instances_cached = true
    @@cached_gce_instances
  end
end
