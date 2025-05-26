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

title 'Ensure That the Default Network Does Not Exist in a Project'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '3.1'
control_abbrev = 'networking'

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'medium'

  title "[#{control_abbrev.upcase}] Ensure That the Default Network Does Not Exist in a Project"

  desc 'To prevent use of default network, a project should not have a default network.'
  desc 'rationale', "The default network has a preconfigured network configuration and automatically generates the following insecure firewall rules:
  - default-allow-internal: Allows ingress connections for all protocols and ports among instances in the network.
  - default-allow-ssh: Allows ingress connections on TCP port 22(SSH) from any source to any instance in the network.
  - default-allow-rdp: Allows ingress connections on TCP port 3389(RDP) from any source to any instance in the network.
  - default-allow-icmp: Allows ingress ICMP traffic from any source to any instance in the network.
  These automatically created firewall rules do not get audit logged by default.
  
  Furthermore, the default network is an auto mode network, which means that its subnets use the same predefined range of IP addresses, and as a result, it's not possible to use Cloud VPN or VPC Network Peering with the default network.

  Based on organization security and networking requirements, the organization should create a new network and delete the default network."

  tag cis_scored: true
  tag cis_level: 2
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['CM-6']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/compute/docs/networking#firewall_rules'
  ref 'GCP Docs', url: 'https://cloud.google.com/compute/docs/reference/latest/networks/insert'
  ref 'GCP Docs', url: 'https://cloud.google.com/compute/docs/reference/latest/networks/delete'
  ref 'GCP Docs', url: 'https://cloud.google.com/vpc/docs/firewall-rules-logging'
  ref 'GCP Docs', url: 'https://cloud.google.com/vpc/docs/vpc#default-network'
  ref 'GCP Docs', url: 'https://cloud.google.com/sdk/gcloud/reference/compute/networks/delete'
  describe "[#{gcp_project_id}] Subnets" do
    subject { google_compute_networks(project: gcp_project_id) }
    its('network_names') { should_not include 'default' }
  end
end
