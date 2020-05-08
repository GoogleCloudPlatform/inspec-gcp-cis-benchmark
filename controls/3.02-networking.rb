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

title 'Ensure legacy networks do not exists for a project'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = '3.2'
control_abbrev = 'networking'

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure legacy networks does not exists for a project"

  desc 'In order to prevent use of legacy networks, a project should not have a legacy network configured.'
  desc 'rationale', 'Legacy networks have a single network IPv4 prefix range and a single gateway IP address for the whole network. The network is global in scope and spans all cloud regions. You cannot create subnetworks in a legacy network or switch from legacy to auto or custom subnet networks. Legacy networks can thus have an impact for high network traffic projects and subject to the single point of contention or failure.'

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/compute/docs/networking#creating_a_legacy_network'
  ref 'GCP Docs', url: 'https://cloud.google.com/compute/docs/networking#legacy_non-subnet_network'

  network_names = google_compute_networks(project: gcp_project_id).network_names

  unless network_names.empty?
    google_compute_networks(project: gcp_project_id).network_names.each do |network|
      describe "[#{gcp_project_id}] Network [#{network}] " do
        subject { google_compute_network(project: gcp_project_id, name: network) }
        it { should_not be_legacy }
      end
    end
  else
    describe "[#{gcp_project_id}] does not have any networks. This test is Not Applicable." do
      skip "[#{gcp_project_id}] does not have any networks."
    end
  end
end
