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

title 'Ensure that corporate login credentials are used instead of Gmail accounts'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "1.1"
control_abbrev = "iam"

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure that corporate login credentials are used instead of Gmail accounts"

  desc "Use corporate login credentials instead of Gmail accounts."
  desc "rationale", "Gmail accounts are personally created and controllable accounts. Organizations seldom have any control over them. Thus, it is recommended that you use fully managed corporate Google accounts for increased visibility, auditing, and control over access to Cloud Platform resources."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations#use_corporate_login_credentials"

  google_project_iam_bindings(project: gcp_project_id).iam_binding_roles.each do |role|
    describe "[#{gcp_project_id}] Role:#{role} Its" do
      subject { google_project_iam_binding(project: gcp_project_id,  role: role) }
      its('members.to_s') { should_not match /gmail.com/ }
    end
  end
end
