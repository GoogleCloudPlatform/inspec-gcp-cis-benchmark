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

title 'Compute instances should not be configured to have external IP addresses.'

gcp_project_id = input('gcp_project_id')
gce_zones = input('gce_zones')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '4.9'
control_abbrev = 'vms'

gce_instances = GCECache(project: gcp_project_id, gce_zones: gce_zones).gce_instances_cache

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'medium'

  title "[#{control_abbrev.upcase}] Compute instances should not be configured to have external IP addresses."

  desc 'Customer-Supplied Encryption Keys (CSEK) are a feature in Google Cloud Storage and Google Compute Engine. If you supply your own encryption keys, Google uses your key to protect the Google-generated keys used to encrypt and decrypt your data. By default, Google Compute Engine encrypts all data at rest. Compute Engine handles and manages this encryption for you without any additional actions on your part. However, if you wanted to control and manage this encryption yourself, you can provide your own encryption keys.'
  desc 'rationale', "To reduce your attack surface, Compute instances should not have public IP addresses. Instead, instances should be configured behind load balancers, to minimize the instance's exposure to the internet."

  tag cis_scored: true
  tag cis_level: 2
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/load-balancing/docs/backend-service#backends_and_external_ip_addresses'
  ref 'GCP Docs', url: 'https://cloud.google.com/compute/docs/instances/connecting-advanced#sshbetweeninstances'
  ref 'GCP Docs', url: 'https://cloud.google.com/compute/docs/instances/connecting-to-instance'
  ref 'GCP Docs', url: 'https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address#unassign_ip'
  ref 'GCP Docs', url: 'https://cloud.google.com/resource-manager/docs/organization-policy/org-policy-constraints'

  gce_instances.each do |instance|
    google_compute_instance(project: gcp_project_id, zone: instance[:zone], name: instance[:name]).network_interfaces.each do |network_interface|
      network_interface.access_configs.each do |access_config|
        describe "[#{gcp_project_id}] Instance #{instance[:zone]}/#{instance[:name]}" do
          subject { access_config.nat_ip }
          it { should be_empty }
        end
      end
    end
  end
end
