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

title 'Ensure default Service account is not used for Project access in Kubernetes Clusters'

gcp_project_id = attribute('gcp_project_id')
gcp_gke_locations = attribute('gcp_gke_locations')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "7.17"
control_abbrev = "gke"

gke_clusters = get_gke_clusters(gcp_project_id, gcp_gke_locations)

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure default Service account is not used for Project access in Kubernetes Clusters"

  desc "A service account is an identity that an instance or an application can use to run API requests on your behalf. This identity is used to identify applications running on your virtual machine instances to other Google Cloud Platform services. By default, Kubernetes Engine nodes are given the Compute Engine default service account. This account has broad access by default, making it useful to a wide variety of applications, but it has more permissions than are required to run your Kubernetes Engine cluster."
  desc "rationale", "You should create and use a minimally privileged service account to run your Kubernetes Engine cluster instead of using the Compute Engine default service account. If you are not creating a separate service account for your nodes, you should limit the scopes of the node service account to reduce the possibility of a privilege escalation in an attack. Kubernetes Engine requires, at a minimum, the service account to have the monitoring.viewer, monitoring.metricWriter, and logging.logWriter roles. This ensures that your default service account does not have permissions beyond those necessary to run your cluster.  While the default scopes are limited, they may include scopes beyond the minimally required scopes needed to run your cluster."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/compute/docs/access/service-accounts#compute_engine_default_service_account"

  gke_clusters.each do |gke_cluster|
    google_container_regional_node_pools(project: gcp_project_id, location: gke_cluster[:location], cluster: gke_cluster[:cluster_name]).names.each do |nodepoolname|
      describe "[#{gcp_project_id}] Cluster #{gke_cluster[:location]}/#{gke_cluster[:cluster_name]}/#{nodepoolname}" do
        subject { google_container_regional_node_pool(project: gcp_project_id, location: gke_cluster[:location], cluster: gke_cluster[:cluster_name], name: nodepoolname) }
        its('config.service_account') { should_not cmp 'default' }
      end
    end    
  end
end
