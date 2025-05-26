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

title 'Ensure that IAM users are not assigned Service Account User role at project level'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '1.6'
control_abbrev = 'iam'

iam_bindings_cache = IAMBindingsCache(project: gcp_project_id)

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'medium'

  title "[#{control_abbrev.upcase}] Ensure that IAM users are not assigned Service Account User role at project level"

  desc "It is recommended to assign the Service Account User (iam.serviceAccountUser) and Service Account Token Creator (iam.serviceAccountTokenCreator) roles to a user for a specific service account rather than assigning the role to a user at project level."
  desc 'rationale', "A service account is a special Google account that belongs to an application or a virtual machine (VM), instead of to an individual end-user. Application/VM-Instance uses the service account to call the service's Google API so that users aren't directly involved. In addition to being an identity, a service account is a resource that has IAM policies attached to it. These policies determine who can use the service account.

  Users with IAM roles to update the App Engine and Compute Engine instances (such as App Engine Deployer or Compute Instance Admin) can effectively run code as the service accounts used to run these instances, and indirectly gain access to all the resources for which the service accounts have access. Similarly, SSH access to a Compute Engine instance may also provide the ability to execute code as that instance/Service account.

  Based on business needs, there could be multiple user-managed service accounts configured for a project. Granting the iam.serviceAccountUser or iam.serviceAccountTokenCreator roles to a user for a project gives the user access to all service accounts in the project, including service accounts that may be created in the future. This can result in elevation of privileges by using service accounts and corresponding Compute Engine instances.

  In order to implement least privileges best practices, IAM users should not be assigned the Service Account User or Service Account Token Creator roles at the project level. Instead, these roles should be assigned to a user for a specific service account, giving that user access to the service account. The Service Account User allows a user to bind a service account to a long-running job service, whereas the Service Account Token Creator role allows a user to directly impersonate (or assert) the identity of a service account."

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
  ref 'GCP Docs', url: 'https://console.cloud.google.com/iam-admin/iam'

  describe "[#{gcp_project_id}] A project-level binding of ServiceAccountUser" do
    subject { iam_bindings_cache.iam_bindings['roles/iam.serviceAccountUser'] }
    it { should eq nil }
  end
end
