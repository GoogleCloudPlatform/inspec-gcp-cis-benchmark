# Copyright 2025 The inspec-gcp-cis-benchmark Authors
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

title 'Ensure Secrets are Not Stored in Cloud Functions Environment Variables by Using Secret Manager'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '1.17'
control_abbrev = 'iam'

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'medium'
  title "[#{control_abbrev.upcase}] Ensure Secrets are Not Stored in Cloud Functions Environment Variables by Using Secret Manager"
  desc 'Google Cloud Functions allow you to host serverless code that is executed when an event is triggered, without the requiring the management a host operating system. These functions can also store environment variables to be used by the code that may contain authentication or other information that needs to remain confidential.'
  desc 'rationale', 'It is recommended to use the Secret Manager, because environment variables are stored unencrypted, and accessible for all users who have access to the code.'

  tag cis_scored: false
  tag cis_level: 1
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['SC-28']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/functions/docs/configuring/env-var#managing_secrets'
  ref 'GCP Docs', url: 'https://cloud.google.com/secret-manager/docs/overview'
  describe 'This control is not scored' do
    skip 'This control is not scored'
  end
end
