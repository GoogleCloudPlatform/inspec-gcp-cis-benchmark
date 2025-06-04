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

title 'Ensure that corporate login credentials are used'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '1.1'
control_abbrev = 'iam'

iam_bindings_cache = IAMBindingsCache(project: gcp_project_id)

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'high'

  title "[#{control_abbrev.upcase}] Ensure that corporate login credentials are used"

  desc 'Use corporate login credentials instead of consumer accounts, such as Gmail accounts.'
  desc 'rationale', "It is recommended fully-managed corporate Google accounts be used for increased visibility, auditing, and controlling access to Cloud Platform resources. Email accounts based outside of the user's organization, such as consumer accounts, should not be used for business purposes."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['AC-2']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://support.google.com/work/android/answer/6371476'
  ref 'GCP Docs', url: 'https://cloud.google.com/sdk/gcloud/reference/projects/get-iam-policy'
  ref 'GCP Docs', url: 'https://cloud.google.com/sdk/gcloud/reference/resource-manager/folders/get-iam-policy'
  ref 'GCP Docs', url: 'https://cloud.google.com/sdk/gcloud/reference/organizations/get-iam-policy'
  ref 'GCP Docs', url: 'https://cloud.google.com/resource-manager/docs/organization-policy/restricting-domains'
  ref 'GCP Docs', url: 'https://cloud.google.com/resource-manager/docs/organization-policy/org-policy-constraints'

  # determine the organization's email domain
  # Use google_project.ancestry to determine the organization ID.  This simplifies the logic and
  # handles more complex hierarchy scenarios.
  org_id = google_project(project: gcp_project_id).ancestry.last
  org_domain = google_organization(name: org_id).display_name

  iam_bindings_cache.iam_binding_roles.each do |role|
    iam_bindings_cache.iam_bindings[role].members.each do |member|
      # Skip service accounts as they are not personal accounts.
      next if member.to_s.end_with?('.gserviceaccount.com')
      # Skip Google-managed service accounts
      next if member.to_s.start_with?('serviceAccount:service-')

      describe "[#{gcp_project_id}] [Role:#{role}] Its member #{member}" do
        subject { member.to_s }
        it { should match(/@#{org_domain}/) }
      end
    end
  end
end
