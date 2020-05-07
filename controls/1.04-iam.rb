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

title 'Ensure that there are only GCP-managed service account keys for each service account'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = '1.4'
control_abbrev = 'iam'

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure that there are only GCP-managed service account keys for each service account"

  desc 'User managed service account should not have user managed keys.'
  desc 'rationale', 'Anyone who has access to the keys will be able to access resources through the service account. GCP-managed keys are used by Cloud Platform services such as App Engine and Compute Engine. These keys cannot be downloaded. Google will keep the keys and automatically rotate them on an approximately weekly basis. User-managed keys are created, downloadable, and managed by users. They expire 10 years from creation.

For user-managed keys, user have to take ownership of key management activities which includes:
- Key storage
- Key distribution
- Key revocation
- Key rotation
- Protecting the keys from unauthorized users
- Key recovery

Even after owners precaution, keys can be easily leaked by common development malpractices like checking keys into the source code or leaving them in Downloads directory, or accidentally leaving them on support blogs/channels.  It is recommended to prevent use of User-managed service account keys.'

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref 'CIS Benchmark', url: "#{cis_url}"
  ref 'GCP Docs', url: 'https://cloud.google.com/iam/docs/understanding-service-accounts#managing_service_account_keys'

  google_service_accounts(project: gcp_project_id).service_account_emails.each do |sa_email|
    if google_service_account_keys(project: gcp_project_id, service_account: sa_email).key_names.count > 1
      impact 1.0
      describe "[#{gcp_project_id}] Service Account: #{sa_email}" do
        subject { google_service_account_keys(project: gcp_project_id, service_account: sa_email) }
        its('key_types') { should_not include 'USER_MANAGED' }
      end
    else
      impact 0
      describe "[#{gcp_project_id}] ServiceAccount [#{sa_email}] does not have user-managed keys. This test is Not Applicable." do
        skip "[#{gcp_project_id}] ServiceAccount [#{sa_email}] does not have user-managed keys."
      end
    end
  end
end
