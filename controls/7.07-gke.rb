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

title "Ensure 'Automatic node repair' is enabled for Kubernetes Clusters"

gcp_project_id = attribute('gcp_project_id')
gcp_gke_locations = attribute('gcp_gke_locations')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "7.7"
control_abbrev = "gke"

gke_clusters = get_gke_clusters(gcp_project_id, gcp_gke_locations)

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure 'Automatic node repair' is enabled for Kubernetes Clusters"

  desc "Kubernetes Engine's node auto-repair feature helps you keep the nodes in your cluster in a healthy, running state. When enabled, Kubernetes Engine makes periodic checks on the health state of each node in your cluster. If a node fails consecutive health checks over an extended time period, Kubernetes Engine initiates a repair process for that node. If you disable node auto-repair at any time during the repair process, the in-progress repairs are not cancelled and still complete for any node currently under repair."
  desc "rationale", "Kubernetes Engine uses the node's health status to determine if a node needs to be repaired. A node reporting a Ready status is considered healthy. Kubernetes Engine triggers a repair action if a node reports consecutive unhealthy status reports for a given time threshold. An unhealthy status can mean:

- A node reports a NotReady status on consecutive checks over the given time threshold (approximately 10 minutes).
- A node does not report any status at all over the given time threshold (approximately 10 minutes).
- A node's boot disk is out of disk space for an extended time period (approximately 30 minutes).

You can enable node auto-repair on a per-node pool basis. When you create a cluster, you can enable or disable auto-repair for the cluster's default node pool. If you create additional node pools, you can enable or disable node auto-repair for those node pools, independent of the auto-repair setting for the default node pool. Kubernetes Engine generates an entry in its operation logs for any automated repair event. You can check the logs by using the gcloud container operations list command."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/kubernetes-engine/docs/concepts/node-auto-repair"

  gke_clusters.each do |gke_cluster|
    google_container_regional_node_pools(project: gcp_project_id, location: gke_cluster[:location], cluster: gke_cluster[:cluster_name]).names.each do |nodepoolname|
      describe "[#{gcp_project_id}] Cluster #{gke_cluster[:location]}/#{gke_cluster[:cluster_name]}, Node Pool: #{nodepoolname}" do
        subject { google_container_regional_node_pool(project: gcp_project_id, location: gke_cluster[:location], cluster: gke_cluster[:cluster_name], name: nodepoolname) }
        its('management.auto_repair') { should cmp true }
      end
    end
  end

end
