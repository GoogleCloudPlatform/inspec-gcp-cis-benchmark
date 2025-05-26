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

title 'Use Identity Aware Proxy (IAP) to Ensure Only Traffic From Google IP Addresses are Allowed'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '3.10'
control_abbrev = 'networking'

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'medium'
  title "[#{control_abbrev.upcase}] Use Identity Aware Proxy (IAP) to Ensure Only Traffic From Google IP Addresses are Allowed"
  desc 'IAP authenticates the user requests to your apps via a Google single sign in. You can then manage these users with permissions to control access. It is recommended to use both IAP permissions and firewalls to restrict this access to your apps with sensitive information.'
  desc 'rationale', 'IAP ensure that access to VMs is controlled by authenticating incoming requests. Access to your apps and the VMs should be restricted by firewall rules that allow only the proxy IAP IP addresses contained in the 35.235.240.0/20 subnet. Otherwise, unauthenticated requests can be made to your apps. To ensure that load balancing works correctly health checks should also be allowed.'

  tag cis_scored: false
  tag cis_level: 2
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['AC-1']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/iap'
  ref 'GCP Docs', url: 'https://cloud.google.com/iap/docs/load-balancer-howto'
  ref 'GCP Docs', url: 'https://cloud.google.com/load-balancing/docs/health-checks'
  ref 'GCP Docs', url: 'https://cloud.google.com/blog/products/identity-security/cloud-iap-enables-context-aware-access-to-vms-via-ssh-and-rdp-without-bastion-hosts'

  describe 'This control is not scored' do
    skip 'This control is not scored'
  end
end