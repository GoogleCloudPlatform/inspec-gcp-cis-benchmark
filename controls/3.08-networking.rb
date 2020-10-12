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

title 'Ensure VPC Flow logs is enabled for every subnet in VPC Network'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '3.8'
control_abbrev = 'networking'

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'low'

  title "[#{control_abbrev.upcase}] Ensure VPC Flow logs is enabled for every subnet in VPC Network"

  desc "Flow Logs is a feature that enables you to capture information about the IP traffic going to and from network interfaces in your VPC Subnets. After you've created a flow log, you can view and retrieve its data in Stackdriver Logging. It is recommended that Flow Logs be enabled for every business critical VPC subnet."
  desc 'rationale', "VPC networks and subnetworks provide logically isolated and secure network partitions where you can launch GCP resources. When Flow Logs is enabled for a subnet, VMs within subnet starts reporting on all TCP and UDP flows. Each VM samples the TCP and UDP flows it sees, inbound and outbound, whether the flow is to or from another VM, a host in your on-premises datacenter, a Google service, or a host on the Internet. If two GCP VMs are communicating, and both are in subnets that have VPC Flow Logs enabled, both VMs report the flows.

Flow Logs supports following use cases:

- Network monitoring
- Understanding network usage and optimizing network traffic expenses
- Network forensics
- Real-time security analysis

Flow Logs provide visibility into network traffic for each VM inside the subnet and can be used to detect anomalous traffic or insight during security workflows."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/vpc/docs/using-flow-logs#enabling_vpc_flow_logging'
  ref 'GCP Docs', url: 'https://cloud.google.com/vpc/'

  google_compute_regions(project: gcp_project_id).region_names.each do |region|
    google_compute_subnetworks(project: gcp_project_id, region: region).subnetwork_names.each do |subnet|
      subnet_obj = google_compute_subnetwork(project: gcp_project_id, region: region, name: subnet)
      next if subnet_obj.purpose == 'INTERNAL_HTTPS_LOAD_BALANCER' # filter subnets for internal HTTPs Load Balancing
      describe "[#{gcp_project_id}] #{region}/#{subnet}" do
        subject { subnet_obj }
        if subnet_obj.methods.include?(:log_config) == true
          it 'should have logging enabled' do
            expect(subnet_obj.log_config.enable).to be true
          end
        end
      end
    end
  end
end
