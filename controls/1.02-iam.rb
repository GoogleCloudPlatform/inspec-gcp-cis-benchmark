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

title 'Ensure that multi-factor authentication is enabled for all non-service accounts'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '1.2'
control_abbrev = 'iam'

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'medium'

  title "[#{control_abbrev.upcase}] Ensure that multi-factor authentication is enabled for all non-service accounts"

  desc 'Setup multi-factor authentication for Google Cloud Platform accounts.'
  desc 'rationale', 'Multi-factor authentication requires more than one mechanism to authenticate a user. This secures your logins from attackers exploiting stolen or weak credentials.'

  tag cis_scored: false
  tag cis_level: 1
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ["IA-2"]

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/solutions/securing-gcp-account-u2f'

  describe 'This control is not scored' do
    skip 'This control is not scored'
  end
end
