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

title 'Ensure that ServiceAccount has no Admin privileges.'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = '1.5'
control_abbrev = 'iam'

iam_bindings_cache = IAMBindingsCache(project: gcp_project_id)

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'medium'

  title "[#{control_abbrev.upcase}] Ensure that ServiceAccount has no Admin privileges."

  desc "A service account is a special Google account that belongs to your application or a VM, instead of to an individual end user. Your application uses the service account to call the Google API of a service, so that the users aren't directly involved. It's recommended not to use admin access for ServiceAccount."
  desc 'rationale', "Service accounts represent service-level security of the Resources (application or a VM) which can be determined by the roles assigned to it. Enrolling ServiceAccount with Admin rights gives full access to assigned application or a VM, ServiceAccount Access holder can perform critical actions like delete, update change settings etc. without the intervention of user, so It's recommended not to have Admin rights.
This recommendation is applicable only for User-Managed user created service account (Service account with nomenclature: SERVICE_ACCOUNT_NAME@PROJECT_ID.iam.gserviceaccount.com)."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/sdk/gcloud/reference/iam/service-accounts/'
  ref 'GCP Docs', url: 'https://cloud.google.com/iam/docs/understanding-roles'
  ref 'GCP Docs', url: 'https://cloud.google.com/iam/docs/understanding-service-accounts'

  iam_bindings_cache.iam_bindings.keys.grep(/admin/i).each do |role|
    describe "[#{gcp_project_id}] Admin roles" do
      subject { iam_bindings_cache.iam_bindings[role] }
      its('members') { should_not include(/@iam.gserviceaccount.com/) }
    end
  end

  describe "[#{gcp_project_id}] Project Editor Role" do
    subject { iam_bindings_cache.iam_bindings['roles/editor'] }
    its('members') { should_not include(/@iam.gserviceaccount.com/) }
  end

  describe "[#{gcp_project_id}] Project Owner Role" do
    subject { iam_bindings_cache.iam_bindings['roles/owner'] }
    its('members') { should_not include(/@iam.gserviceaccount.com/) }
  end
end
