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

title 'Ensure the default network does not exist in a project'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = '3.1'
control_abbrev = 'networking'

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'medium'

  title "[#{control_abbrev.upcase}] Ensure the default network does not exist in a project"

  desc 'To prevent use of default network, a project should not have a default network.'
  desc 'rationale', 'The default network has automatically created firewall rules and has pre-fabricated network configuration. Based on your security and networking requirements, you should create your network and delete the default network.'

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/compute/docs/networking#firewall_rules'
  ref 'GCP Docs', url: 'https://cloud.google.com/compute/docs/reference/latest/networks/insert'
  ref 'GCP Docs', url: 'https://cloud.google.com/compute/docs/reference/latest/networks/delete'

  describe "[#{gcp_project_id}] Subnets" do
    subject { google_compute_networks(project: gcp_project_id) }
    its('network_names') { should_not include 'default' }
  end

end
