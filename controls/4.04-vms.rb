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

title 'Ensure oslogin is enabled for a Project'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = '4.4'
control_abbrev = 'vms'

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'medium'

  title "[#{control_abbrev.upcase}] Ensure oslogin is enabled for a Project"

  desc 'Enabling OS login binds SSH certificates to IAM users and facilitates effective SSH certificate management.'
  desc 'rationale', 'Enabling osLogin ensures that SSH keys used to connect to instances are mapped with IAM users. Revoking access to IAM user will revoke all the SSH keys associated with that particular user. It facilitates centralized and automated SSH key pair management which is useful in handling cases like response to compromised SSH key pairs and/or revocation of external/third-party/Vendor users.'

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/compute/docs/instances/managing-instance-access'
  ref 'GCP Docs', url: 'https://cloud.google.com/compute/docs/instances/managing-instance-access#enable_oslogin'

  describe "[#{gcp_project_id}]" do
    subject { google_compute_project_info(project: gcp_project_id) }
    it { should have_enabled_oslogin }
  end
end
