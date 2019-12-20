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

title 'Ensure that IP forwarding is not enabled on Instances'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "4.5"
control_abbrev = "vms"

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure that IP forwarding is not enabled on Instances"

  desc "Compute Engine instance cannot forward a packet unless the source IP address of the packet matches the IP address of the instance. Similarly, GCP won't deliver a packet whose destination IP address is different than the IP address of the instance receiving the packet.  However, both capabilities are required if you want to use instances to help route packets.  Forwarding of data packets should be disabled to prevent data loss or information disclosure."
  desc "rationale", "Compute Engine instance cannot forward a packet unless the source IP address of the packet matches the IP address of the instance. Similarly, GCP won't deliver a packet whose destination IP address is different than the IP address of the instance receiving the packet.  However, both capabilities are required if you want to use instances to help route packets.  To enable this source and destination IP check, disable the canIpForward field, which allows an instance to send and receive packets with non-matching destination or source IPs."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/compute/docs/networking#canipforward"

  google_compute_zones(project: gcp_project_id).zone_names.each do |zone|
    google_compute_instances(project: gcp_project_id, zone: zone).instance_names.each do |instance|
      next if instance =~ /^gke-/
      describe "[#{gcp_project_id}] #{zone}/#{instance}" do
        subject { google_compute_instance(project: gcp_project_id, zone: zone, name: instance) }
        its('can_ip_forward') { should be false }
      end
    end
  end

end
