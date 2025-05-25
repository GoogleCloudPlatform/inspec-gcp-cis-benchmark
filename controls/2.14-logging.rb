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

title "Ensure 'Access Transparency' is 'Enabled' (Manual)"

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
# org_id = input('org_id') # Potentially for future use if InSpec resource becomes available
control_id = '2.14'
control_abbrev = 'logging'

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'medium'

  title "[#{control_abbrev.upcase}] Ensure 'Access Transparency' is 'Enabled' (Manual)"

  desc "GCP Access Transparency provides audit logs for all actions that Google personnel take in your Google Cloud resources."
  desc 'rationale', "Controlling access to your information is one of the foundations of information security. Given that Google Employees do have access to your organizations' projects for support reasons, you should have logging in place to view who, when, and why your information is being accessed. To use Access Transparency your organization will need to have at one of the following support level: Premium, Enterprise, Platinum, or Gold. There will be subscription costs associated with support, as well as increased storage costs for storing the logs."

  tag cis_scored: false
  tag cis_level: 2
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: %w[] # Add relevant NIST controls if any in future

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/cloud-provider-access-management/access-transparency/docs/overview'
  ref 'GCP Docs', url: 'https://cloud.google.com/cloud-provider-access-management/access-transparency/docs/enable'
  ref 'GCP Docs', url: 'https://cloud.google.com/cloud-provider-access-management/access-transparency/docs/reading-logs'
  ref 'GCP Docs', url: 'https://cloud.google.com/cloud-provider-access-management/access-transparency/docs/reading-logs#justification_reason_codes'
  ref 'GCP Docs', url: 'https://cloud.google.com/cloud-provider-access-management/access-transparency/docs/supported-services'

  describe 'This control is not scored' do
    skip 'This control is not scored'
  end
end
