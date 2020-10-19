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

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
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
    role_bindings = iam_bindings_cache.iam_bindings[role]
    if role_bindings.members.nil?
      impact 'none'
      describe "[#{gcp_project_id}] Role bindings for role [#{role}] do not contain any members. This test is Not Applicable." do
        skip "[#{gcp_project_id}] role bindings for role [#{role}] do not contain any members."
      end
    else
      describe "[#{gcp_project_id}] Admin role [#{role}]" do
        subject { role_bindings }
        its('members') { should_not include(/@[a-z][a-z0-9|-]{4,28}[a-z].iam.gserviceaccount.com/) }
      end
    end
  end

  iam_bindings_cache.iam_bindings.keys.grep(%r{roles/editor}).each do |role|
    members_in_scope = []
    iam_bindings_cache.iam_bindings[role].members.each do |member|
      next if member.include? '@containerregistry.iam.gserviceaccount.com'
      members_in_scope.push(member)
    end
    describe "[#{gcp_project_id}] Project Editor Role" do
      subject { members_in_scope }
      it { should_not include(/@[a-z][a-z0-9|-]{4,28}[a-z].iam.gserviceaccount.com/) }
    end
  end

  iam_bindings_cache.iam_bindings.keys.grep(%r{roles/owner}).each do |role|
    describe "[#{gcp_project_id}] Project Owner Role" do
      subject { iam_bindings_cache.iam_bindings[role] }
      its('members') { should_not include(/@[a-z][a-z0-9|-]{4,28}[a-z].iam.gserviceaccount.com/) }
    end
  end
end
