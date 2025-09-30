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

title "Ensure 'Access Approval' is 'Enabled'"

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '2.15'
control_abbrev = 'logging' # Retaining 'logging' as per existing convention for this section

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'medium'

  title "[#{control_abbrev.upcase}] Ensure 'Access Approval' is 'Enabled'"

  desc "GCP Access Approval enables you to require your organizations' explicit approval whenever Google support try to access your projects. You can then select users within your organization who can approve these requests through giving them a security role in IAM. All access requests display which Google Employee requested them in an email or Pub/Sub message that you can choose to Approve. This adds an additional control and logging of who in your organization approved/denied these requests."
  desc 'rationale', "Controlling access to your information is one of the foundations of information security. Google Employees do have access to your organizations' projects for support reasons. With Access Approval, organizations can then be certain that their information is accessed by only approved Google Personnel. Note: To use Access Approval your organization will need have enabled Access Transparency and have at one of the following support level: Enhanced or Premium. There will be subscription costs associated with these support levels, as well as increased storage costs for storing the logs. There may also be a potential delay in support times if approval is not granted promptly."

  tag cis_scored: false
  tag cis_level: 2
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: %w[] # Add relevant NIST controls if any in future

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/cloud-provider-access-management/access-approval/docs'
  ref 'GCP Docs', url: 'https://cloud.google.com/cloud-provider-access-management/access-approval/docs/overview'
  ref 'GCP Docs', url: 'https://cloud.google.com/cloud-provider-access-management/access-approval/docs/quickstart-custom-key'
  ref 'GCP Docs', url: 'https://cloud.google.com/cloud-provider-access-management/access-approval/docs/supported-services'
  ref 'GCP Docs', url: 'https://cloud.google.com/cloud-provider-access-management/access-approval/docs/view-historical-requests'

  describe 'This control is not scored' do
    skip 'This control is not scored'
  end
end
