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

# Cache for GKE cluster list.
#
class GKECache < GCPBaseCache
  name 'GKECache'
  desc 'The GKE cache resource contains functions consumed by the CIS/PCI
       Google profiles:
       https://github.com/GoogleCloudPlatform/inspec-gcp-cis-benchmark'
  attr_reader :gke_locations

  @@cached_gke_clusters = []
  @@gke_clusters_cached = false

  def initialize(params = {})
    super(params) # Pass all parameters to the parent class (GCPBaseCache)
    # @gcp_project_id is now set by the superclass from params[:project]

    # Extract gke_locations from params and handle default
    @gke_locations = if params[:gke_locations] && !params[:gke_locations].empty?
                       params[:gke_locations]
                     else
                       all_gcp_locations # This method is defined in GCPBaseCache
                     end
  end

  def gke_clusters_cache
    set_gke_clusters_cache unless gke_cached?
    @@cached_gke_clusters
  end

  def gke_cached?
    @@gke_clusters_cached
  end

  def set_gke_clusters_cache
    @@cached_gke_clusters = []
    collect_gke_clusters_by_location(@gke_locations)
    @@gke_clusters_cached = true
  end

  private

  def collect_gke_clusters_by_location(gke_locations)
    gke_locations.each do |gke_location|
      inspec.google_container_clusters(project: @gcp_project_id,
                                       location: gke_location).cluster_names
            .each do |gke_cluster|
        @@cached_gke_clusters.push({ cluster_name: gke_cluster,
                                     location: gke_location })
      end
    end
  end
end
