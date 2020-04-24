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

title 'Ensure that corporate login credentials are used'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = '1.1'
control_abbrev = 'iam'

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure that corporate login credentials are used"

  desc "Use corporate login credentials instead of personal accounts, such as Gmail accounts."
  desc "rationale", "It is recommended fully-managed corporate Google accounts be used for increased visibility, auditing, and controlling access to Cloud Platform resources. Email accounts based outside of the user's organization, such as personal accounts, should not be used for business purposes."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations#use_corporate_login_credentials"

  # determine the organization's email domain
  case google_project(project: gcp_project_id).parent.type
  when 'organization'
    org_domain = google_organization(name: "organizations/#{google_project(project: gcp_project_id).parent.id}").display_name
  when 'folder'
    parent = 'folder'
    folder_id = google_project(project: gcp_project_id).parent.id
    while parent == 'folder'
      if google_resourcemanager_folder(name: "folders/#{folder_id}").parent.include?('folders')
        folder_id = google_resourcemanager_folder(name: "folders/#{folder_id}").parent.sub('folders/', '')
      else
        parent = 'organization'
        org_domain = google_organization(name: "#{google_resourcemanager_folder(name: "folders/#{folder_id}").parent}").display_name
      end
    end
  end

  google_project_iam_bindings(project: gcp_project_id).iam_binding_roles.each do | role |
    google_project_iam_binding(project: gcp_project_id,  role: role).members.each do | member |
      next if member.to_s.end_with?('.gserviceaccount.com')
      describe "[#{gcp_project_id}] [Role:#{role}] Its member #{member}" do
        subject { member.to_s }
        it { should match /@#{org_domain}/ }
      end
    end
  end
end
