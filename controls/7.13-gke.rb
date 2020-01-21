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

title 'Ensure Kubernetes Cluster is created with Alias IP ranges enabled'

gcp_project_id = attribute('gcp_project_id')
gcp_gke_locations = attribute('gcp_gke_locations')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "7.13"
control_abbrev = "gke"

gke_clusters = get_gke_clusters(gcp_project_id, gcp_gke_locations)

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure Kubernetes Cluster is created with Alias IP ranges enabled"

  desc "Google Cloud Platform Alias IP Ranges lets you assign ranges of internal IP addresses as aliases to a virtual machine's network interfaces. This is useful if you have multiple services running on a VM and you want to assign each service a different IP address."
  desc "rationale", "With Alias IPs ranges enabled, Kubernetes Engine clusters can allocate IP addresses from a CIDR block known to Google Cloud Platform. This makes your cluster more scalable and allows your cluster to better interact with other GCP products and entities. Using Alias IPs has several benefits:

- Pod IPs are reserved within the network ahead of time, which prevents conflict with other compute resources.
- The networking layer can perform anti-spoofing checks to ensure that egress traffic is not sent with arbitrary source IPs.
- Firewall controls for Pods can be applied separately from their nodes.
- Alias IPs allow Pods to directly access hosted services without using a NAT gateway."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips"
  ref "GCP Docs", url: "https://cloud.google.com/vpc/docs/alias-ip"

  gke_clusters.each do |gke_cluster|
    describe "[#{gcp_project_id}] Cluster #{gke_cluster[:location]}/#{gke_cluster[:cluster_name]}" do
      subject { google_container_regional_cluster(project: gcp_project_id, location: gke_cluster[:location], name: gke_cluster[:cluster_name]) }
      its('ip_allocation_policy.use_ip_aliases') { should cmp true }
    end
  end
end
