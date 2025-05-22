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

title 'Ensure that IAM users are not assigned Service Account User or Service Account Token Creator roles at project level'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '1.6'
control_abbrev = 'iam'

iam_bindings_cache = IAMBindingsCache(project: gcp_project_id)

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'medium'
  title "[#{control_abbrev.upcase}] Ensure that IAM users are not assigned Service Account User or Service Account Token Creator roles at project level"
  desc "It is recommended to assign Service Account User (iam.serviceAccountUser) and Service Account Token Creator (iam.serviceAccountTokenCreator) roles to a user for a specific service account rather than assigning the role to a user at project level."
  desc 'rationale', "Granting these roles at the project level allows users access to all service accounts in the project, potentially leading to privilege escalation.  It's best to grant these roles at the service account level for least privilege."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: %w[AC-2 AC-3]

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/iam/docs/service-accounts'
  ref 'GCP Docs', url: 'https://cloud.google.com/iam/docs/granting-roles-to-service-accounts'
  ref 'GCP Docs', url: 'https://cloud.google.com/iam/docs/understanding-roles'
  ref 'GCP Docs', url: 'https://cloud.google.com/iam/docs/granting-changing-revoking-access'

  describe "[#{gcp_project_id}] A project-level binding of ServiceAccountUser" do
    subject { iam_bindings_cache.iam_bindings['roles/iam.serviceAccountUser'] }
    it { should eq nil }
  end
  describe "[#{gcp_project_id}] A project-level binding of ServiceAccountUser" do
    subject { iam_bindings_cache.iam_bindings['roles/iam.serviceAccountTokenCreator'] }
    it { should eq nil }
  end  
end
