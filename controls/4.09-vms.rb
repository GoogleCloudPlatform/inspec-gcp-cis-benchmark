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

title 'Ensure That Compute Instances Do Not Have Public IP Addresses (Automated)'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '4.09'
control_abbrev = 'vms'

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'medium'

  title "[#{control_abbrev.upcase}] Ensure That Compute Instances Do Not Have Public IP Addresses (Automated)"

  desc 'Compute instances should not be configured to have external IP addresses. Removing the external IP address from your Compute instance may cause some applications to stop working.'
  desc 'rationale', "To reduce your attack surface, Compute instances should not have public IP addresses. Instead, instances should be configured behind load balancers, to minimize the instance's exposure to the internet."

  tag cis_scored: true
  tag cis_level: 2
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: %w[] # Add relevant NIST controls if any in future

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/load-balancing/docs/backend-service#backends_and_external_ip_addresses'
  ref 'GCP Docs', url: 'https://cloud.google.com/compute/docs/instances/connecting-advanced#sshbetweeninstances'
  ref 'GCP Docs', url: 'https://cloud.google.com/compute/docs/instances/connecting-to-instance'
  ref 'GCP Docs', url: 'https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address#unassign_ip'
  ref 'GCP Docs', url: 'https://cloud.google.com/resource-manager/docs/organization-policy/org-policy-constraints'
  ref 'Organization Policy', url: 'https://console.cloud.google.com/orgpolicies/compute-vmExternalIpAccess'

  # control_id and control_abbrev are already defined above

  instances_found = false
  google_compute_zones(project: gcp_project_id).zone_names.each do |zone_name|
    google_compute_instances(project: gcp_project_id, zone: zone_name)
      .where { instance_name !~ /^gke-/ }
      .where(status: 'RUNNING')
      .instance_names.each do |instance_name|
        instances_found = true
        describe "[#{gcp_project_id}] Instance: #{instance_name} in Zone: #{zone_name}" do
          subject { google_compute_instance(project: gcp_project_id, zone: zone_name, name: instance_name) }
          it 'should not have an external IP assigned' do
            subject.network_interfaces.each do |iface|
              has_external_ip = iface.access_configs&.any? { |ac| !ac.nat_ip.nil? && !ac.nat_ip.empty? }
              expect(has_external_ip).to be_falsey
            end
          end
        end
      end
  end

  unless instances_found
    describe "[#{control_abbrev.upcase}] #{control_id} - No Non-GKE Running Instances Found" do
      skip 'No non-GKE running compute instances were found in the project, this control is Not Applicable.'
    end
  end
end
