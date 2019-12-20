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

    def get_gke_clusters(gcp_project_id)
      unless @gke_clusters_cached == true
        @cached_gke_clusters = []
        begin
          @gke_locations = google_compute_zones(project: gcp_project_id).zone_names
          @gke_locations += google_compute_regions(project: gcp_project_id).region_names

          @gke_locations.each do |gke_location|
            google_container_regional_clusters(project: gcp_project_id, location: gke_location).names.each do |gke_cluster|
              @cached_gke_clusters.push({:cluster_name => gke_cluster, :location => gke_location})
            end
          end
          @gke_clusters_cached = true
        rescue NoMethodError
          # During inspec check, the mock transport connection doesn't set up a gcp_compute_client method
        end
      end
      return @cached_gke_clusters
    end

end

::Inspec::DSL.include(GcpHelpers)
