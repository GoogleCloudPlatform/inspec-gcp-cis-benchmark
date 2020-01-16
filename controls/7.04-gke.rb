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

title 'Ensure Master authorized networks is set to Enabled on Kubernetes Engine Clusters'

gcp_project_id = attribute('gcp_project_id')
gcp_gke_locations = attribute('gcp_gke_locations')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "7.4"
control_abbrev = "gke"

gke_clusters = get_gke_clusters(gcp_project_id, gcp_gke_locations)

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure Master authorized networks is set to Enabled on Kubernetes Engine Clusters"

  desc "Authorized networks are a way of specifying a restricted range of IP addresses that are permitted to access your container cluster's Kubernetes master endpoint. Kubernetes Engine uses both Transport Layer Security (TLS) and authentication to provide secure access to your container cluster's Kubernetes master endpoint from the public internet.  This provides you the flexibility to administer your cluster from anywhere; however, you might want to further restrict access to a set of IP addresses that you control. You can set this restriction by specifying an authorized network."
  desc "rationale", "By Enabling, Master authorized networks blocks untrusted IP addresses from outside Google Cloud Platform and Addresses from inside GCP (such as traffic from Compute Engine VMs) can reach your master through HTTPS provided that they have the necessary Kubernetes credentials.

Restricting access to an authorized network can provide additional security benefits for your container cluster, including:

- Better Protection from Outsider Attacks: Authorized networks provide an additional layer of security by limiting external, non-GCP access to a specific set of addresses you designate, such as those that originate from your premises. This helps protect access to your cluster in the case of a vulnerability in the cluster's authentication or authorization mechanism.
- Better Protection from Insider Attacks: Authorized networks help protect your cluster from accidental leaks of master certificates from your company's premises.  Leaked certificates used from outside GCP and outside the authorized IP ranges--for example, from addresses outside your company--are still denied access."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/kubernetes-engine/docs/how-to/authorized-networks"

  gke_clusters.each do |gke_cluster|
    describe "[#{gcp_project_id}] Cluster #{gke_cluster[:location]}/#{gke_cluster[:cluster_name]}" do
      subject { google_container_regional_cluster(project: gcp_project_id, location: gke_cluster[:location], name: gke_cluster[:cluster_name]) }
      its('master_authorized_networks_config.cidr_blocks') { should_not be_empty }
      its('master_authorized_networks_config.cidr_blocks.to_s') { should_not match /0.0.0.0\/0/ }
    end
  end

end
