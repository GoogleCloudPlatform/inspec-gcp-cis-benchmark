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

title "Ensure the Latest Operating System Updates Are Installed On Your Virtual Machines in All Projects (Manual)"

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '4.12'
control_abbrev = 'vms'

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'medium'

  title "[#{control_abbrev.upcase}] Ensure the Latest Operating System Updates Are Installed On Your Virtual Machines in All Projects (Manual)"

  desc "Google Cloud Virtual Machines have the ability via an OS Config agent API to periodically (about every 10 minutes) report OS inventory data. A patch compliance API periodically reads this data, and cross references metadata to determine if the latest updates are installed. This is not the only Patch Management solution available to your organization and you should weigh your needs before committing to using this method. Most Operating Systems require a restart or changing critical resources to apply the updates. Using the Google Cloud VM manager for its OS Patch management will incur additional costs for each VM managed by it."
  desc 'rationale', "Keeping virtual machine operating systems up to date is a security best practice. Using this service will simplify this process."

  tag cis_scored: false
  tag cis_level: 2
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: %w[] # Add relevant NIST controls if any in future

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs - Manage OS', url: 'https://cloud.google.com/compute/docs/manage-os'
  ref 'GCP Docs - OS Patch Management', url: 'https://cloud.google.com/compute/docs/os-patch-management'
  ref 'GCP Docs - VM Manager', url: 'https://cloud.google.com/compute/docs/vm-manager'
  ref 'GCP Docs - OS Details VM Manager', url: 'https://cloud.google.com/compute/docs/images/os-details#vm-manager'
  ref 'GCP Docs - VM Manager Pricing', url: 'https://cloud.google.com/compute/docs/vm-manager#pricing'
  ref 'GCP Docs - Verify Setup', url: 'https://cloud.google.com/compute/docs/troubleshooting/vm-manager/verify-setup'
  ref 'GCP Docs - View OS Details', url: 'https://cloud.google.com/compute/docs/instances/view-os-details#view-data-tools'
  ref 'GCP Docs - Create Patch Job', url: 'https://cloud.google.com/compute/docs/os-patch-management/create-patch-job'
  ref 'GCP Docs - Setup NAT', url: 'https://cloud.google.com/nat/docs/set-up-network-address-translation'
  ref 'GCP Docs - Private Google Access', url: 'https://cloud.google.com/vpc/docs/configure-private-google-access'
  ref 'CIS Workbench Ref', url: 'https://workbench.cisecurity.org/sections/811638/recommendations/1334335'
  ref 'GCP Docs - OS Agent Install', url: 'https://cloud.google.com/compute/docs/manage-os#agent-install'
  ref 'GCP Docs - Verify SA Enabled', url: 'https://cloud.google.com/compute/docs/troubleshooting/vm-manager/verify-setup#service-account-enabled'
  ref 'GCP Docs - OS Patch Dashboard', url: 'https://cloud.google.com/compute/docs/os-patch-management#use-dashboard'
  ref 'GCP Docs - Verify Metadata Enabled', url: 'https://cloud.google.com/compute/docs/troubleshooting/vm-manager/verify-setup#metadata-enabled'

  describe 'This control is not scored' do
    skip 'This control is not scored'
  end
end
