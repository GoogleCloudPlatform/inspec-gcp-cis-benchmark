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

title 'Ensure Private Google Access is enabled for all subnetwork in VPC Network'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "3.8"
control_abbrev = "networking"

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure Private Google Access is enabled for all subnetwork in VPC Network"

  desc "Private Google Access enables virtual machine instances on a subnet to reach Google APIs and services using an internal IP address rather than an external IP address. External IP addresses are routable and reachable over the Internet. Internal (private) IP addresses are internal to Google Cloud Platform and are not routable or reachable over the Internet. You can use Private Google Access to allow VMs without Internet access to reach Google APIs, services, and properties that are accessible over HTTP/HTTPS."
  desc "rationale", "VPC networks and subnetworks provide logically isolated and secure network partitions where you can launch GCP resources. When Private Google Access is enabled, VM instances in a subnet can reach the Google Cloud and Developer APIs and services without needing an external IP address. Instead, VMs can use their internal IP addresses to access Google managed services. Instances with external IP addresses are not affected when you enable the ability to access Google services from internal IP addresses. These instances can still connect to Google APIs and managed services."

  tag cis_scored: true
  tag cis_level: 2
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/vpc/docs/configure-private-google-access"
  ref "GCP Docs", url: "https://cloud.google.com/vpc/docs/private-google-access"

  google_compute_regions(project: gcp_project_id).region_names.each do |region|
    google_compute_subnetworks(project: gcp_project_id, region: region).subnetwork_names.each do |subnet|
      describe "[#{gcp_project_id}] Subnet: #{region}/#{subnet} its" do 
        subject { google_compute_subnetwork(project: gcp_project_id, region: region, name: subnet) }
        its('private_ip_google_access') { should be true }
      end
    end
  end
end
