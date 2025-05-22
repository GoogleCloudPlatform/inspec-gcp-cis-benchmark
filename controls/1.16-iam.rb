# Copyright 2025 The inspec-gcp-cis-benchmark Authors
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

title 'Ensure Essential Contacts is Configured for Organization'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '1.16'
control_abbrev = 'iam'

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'low'
  title "[#{control_abbrev.upcase}] Ensure Essential Contacts is Configured for Organization"
  desc 'Essential Contacts should be configured for the organization.'
  desc 'rationale', 'Essential Contacts ensures that Google can reach the appropriate individuals in case of security incidents or other important events related to your organization.  Specifically, this control checks for LEGAL, SECURITY, SUSPENSIONS, and TECHNICAL contacts.'

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['CP-2']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/resource-manager/docs/managing-notification-contacts'

  # Get the organization ID.
  org_id = google_project(project: gcp_project_id).ancestry.last

  # Get essential contacts for the organization using gcloud.
  contacts_output = command("gcloud essential-contacts list --organization=#{org_id} --format='json(contacts)'").stdout

  begin
    contacts = JSON.parse(contacts_output)['contacts']
  rescue JSON::ParserError => e
    describe 'Error parsing essential contacts output' do
      subject { contacts_output }
      it { should_not be_empty }
    end
    return # Stop the control if parsing fails
  end

  required_contact_types = ['LEGAL', 'SECURITY', 'SUSPENSIONS', 'TECHNICAL']

  required_contact_types.each do |contact_type|
    describe "[#{org_id}] Essential Contact: #{contact_type}" do
      subject { contacts.select { |c| c['type'] == contact_type } }
      it { should_not be_empty }
    end
  end
end