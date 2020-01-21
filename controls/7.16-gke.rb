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

title 'Ensure Private Google Access is set on Kubernetes Engine Cluster Subnets'

gcp_project_id = attribute('gcp_project_id')
gcp_gke_locations = attribute('gcp_gke_locations')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "7.16"
control_abbrev = "gke"

gke_clusters = get_gke_clusters(gcp_project_id, gcp_gke_locations)

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure Private Google Access is set on Kubernetes Engine Cluster Subnets"

  desc "Private Google Access enables your cluster hosts, which have only private IP addresses, to communicate with Google APIs and services using an internal IP address rather than an external IP address. External IP addresses are routable and reachable over the Internet.  Internal (private) IP addresses are internal to Google Cloud Platform and are not routable or reachable over the Internet. You can use Private Google Access to allow VMs without Internet access to reach Google APIs, services, and properties that are accessible over HTTP/HTTPS."
  desc "rationale", "VPC networks and subnetworks provide logically isolated and secure network partitions where you can launch GCP resources. When Private Google Access is enabled, VM instances in a subnet can reach the Google Cloud and Developer APIs and services without needing an external IP address. Instead, VMs can use their internal IP addresses to access Google managed services. Instances with external IP addresses are not affected when you enable the ability to access Google services from internal IP addresses. These instances can still connect to Google APIs and managed services."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/vpc/docs/configure-private-google-access"
  ref "GCP Docs", url: "https://cloud.google.com/vpc/docs/private-google-access"

  gke_clusters.each do |gke_cluster|
    gke_cluster_details = google_container_regional_cluster(project: gcp_project_id, location: gke_cluster[:location], name: gke_cluster[:cluster_name])
    gke_subnet = gke_cluster_details.subnetwork
    gke_subnet_region = gke_cluster_details.location.split("-").slice(0 .. 1).join("-")

    describe "[#{gcp_project_id}] Cluster #{gke_cluster[:location]}/#{gke_cluster[:cluster_name]} Subnet #{gke_subnet}" do
      subject { google_compute_subnetwork(project: gcp_project_id, region: gke_subnet_region, name: gke_subnet) }
      its('private_ip_google_access') { should cmp true }
    end
  end

end
