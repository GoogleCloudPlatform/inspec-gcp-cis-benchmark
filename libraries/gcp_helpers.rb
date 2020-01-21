# encoding: utf-8
# Copyright 2019 The inspec-gcp-cis-benchmark Authors
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

module GcpHelpers

    @gke_clusters_cached = false
    @gke_locations = []

    def get_gke_clusters(gcp_project_id, gcp_gke_locations)
      unless @gke_clusters_cached == true
        # Reset the list of cached clusters
        @cached_gke_clusters = []
        begin
          # If we weren't passed a specific list/array of zones/region names from inputs, search everywhere 
          if gcp_gke_locations.empty?
            @gke_locations = google_compute_zones(project: gcp_project_id).zone_names
            @gke_locations += google_compute_regions(project: gcp_project_id).region_names
          else
            @gke_locations = gcp_gke_locations
          end

          # Loop/fetch/cache the names and locations of GKE clusters
          @gke_locations.each do |gke_location|
            google_container_regional_clusters(project: gcp_project_id, location: gke_location).names.each do |gke_cluster|
              @cached_gke_clusters.push({:cluster_name => gke_cluster, :location => gke_location})
            end
          end
          # Mark the cache as full
          @gke_clusters_cached = true
        rescue NoMethodError
          # During inspec check, the mock transport connection doesn't set up a gcp_compute_client method
        end
      end
      # Return the list of clusters
      return @cached_gke_clusters
    end

end

::Inspec::DSL.include(GcpHelpers)
