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

title 'Ensure Automatic node upgrades is enabled on Kubernetes Engine Clusters nodes'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "7.8"
control_abbrev = "gke"

gke_clusters = get_gke_clusters(gcp_project_id)

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure Automatic node upgrades is enabled on Kubernetes Engine Clusters nodes"

  desc "Node auto-upgrades help you keep the nodes in your cluster or node pool up to date with the latest stable version of Kubernetes. Auto-Upgrades use the same update mechanism as manual node upgrades."
  desc "rationale", "Node pools with auto-upgrades enabled are automatically scheduled for upgrades when a new stable Kubernetes version becomes available. When the upgrade is performed, the node pool is upgraded to match the current cluster master version. Some benefits of using enabling auto-upgrades are:

- Lower management overhead: You don't have to manually track and update to the latest version of Kubernetes.
- Better security: Sometimes new binaries are released to fix a security issue. With auto-upgrades, Kubernetes Engine automatically ensures that security updates are applied and kept up to date.
- Ease of use: Provides a simple way to keep your nodes up to date with the latest Kubernetes features."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/kubernetes-engine/docs/concepts/node-auto-upgrades"

  gke_clusters.each do |gke_cluster|
    google_container_regional_node_pools(project: gcp_project_id, location: gke_cluster[:location], cluster: gke_cluster[:cluster_name]).names.each do |nodepoolname|
      describe "[#{gcp_project_id}] Cluster #{gke_cluster[:location]}/#{gke_cluster[:cluster_name]}, Node Pool: #{nodepoolname}" do
        subject { google_container_regional_node_pool(project: gcp_project_id, location: gke_cluster[:location], cluster: gke_cluster[:cluster_name], name: nodepoolname) }
        its('management.auto_upgrade') { should cmp true }
      end
    end
  end

end
