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

# Base Class for GCP Cache Classes
#
class GCPBaseCache < Inspec.resource(1)
  name 'GCPBaseCache'
  desc 'The GCP Base cache resource is inherited by more specific cache
       classes (e.g. GCE, GKE). The cache is consumed by the CIS and PCI
       Google Inspec profiles:
       https://github.com/GoogleCloudPlatform/inspec-gcp-cis-benchmark'
  attr_reader :gke_locations

  def initialize(params = {})
    super()
    @gcp_project_id = params[:project] # Extract the project from the params hash
    @gke_locations = []
  end

  protected

  def all_gcp_locations
    locations = inspec.google_compute_zones(project: @gcp_project_id).zone_names
    locations += inspec.google_compute_regions(project: @gcp_project_id)
                       .region_names
    locations
  end
end
