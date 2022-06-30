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

title 'Ensure that Separation of duties is enforced while assigning service account related roles to users'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '1.8'
control_abbrev = 'iam'

iam_bindings_cache = IAMBindingsCache(project: gcp_project_id)

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'none'

  title "[#{control_abbrev.upcase}] Ensure that Separation of duties is enforced while assigning service account related roles to users"

  desc "It is recommended that the principle of 'Separation of Duties' is enforced while assigning service account related roles to users."
  desc 'rationale', "Built-in/Predefined IAM role Service Account admin allows user/identity to create, delete, manage service account(s). Built-in/Predefined IAM role Service Account User allows user/identity (with adequate privileges on Compute and App Engine) to assign service account(s) to Apps/Compute Instances.

Separation of duties is the concept of ensuring that one individual does not have all necessary permissions to be able to complete a malicious action. In Cloud IAM - service accounts, this could be an action such as using a service account to access resources that user should not normally have access to. Separation of duties is a business control typically used in larger organizations, meant to help avoid security or privacy incidents and errors.  It is considered best practice.

Any user(s) should not have Service Account Admin and Service Account User, both roles assigned at a time."

  tag cis_scored: false
  tag cis_level: 2
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: %w[AC-2 AC-3]

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/iam/docs/service-accounts'
  ref 'GCP Docs', url: 'https://cloud.google.com/iam/docs/understanding-roles'
  ref 'GCP Docs', url: 'https://cloud.google.com/iam/docs/granting-roles-to-service-accounts'

  sa_admins = iam_bindings_cache.iam_bindings['roles/iam.serviceAccountAdmin']
  if sa_admins.nil? || sa_admins.members.count.zero?
    describe "[#{gcp_project_id}] does not contain users with roles/serviceAccountAdmin. This test is Not Applicable." do
      skip "[#{gcp_project_id}] does not contain users with roles/serviceAccountAdmin"
    end
  elsif iam_bindings_cache.iam_bindings['roles/iam.serviceAccountUser'].nil?
    describe "[#{gcp_project_id}] does not contain users with roles/serviceAccountUser. This test is Not Applicable." do
      skip "[#{gcp_project_id}] does not contain users with roles/serviceAccountUser"
    end
  else
    impact 'medium'
    describe "[#{gcp_project_id}] roles/serviceAccountUser" do
      subject { iam_bindings_cache.iam_bindings['roles/iam.serviceAccountUser'] }
      sa_admins.members.each do |sa_admin|
        its('members.to_s') { should_not match sa_admin }
      end
    end
  end
end
