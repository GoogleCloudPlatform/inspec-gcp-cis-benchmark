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

title 'Ensure Kubernetes Clusters created with limited service account Access scopes for Project access'

gcp_project_id = attribute('gcp_project_id')
gcp_gke_locations = attribute('gcp_gke_locations')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "7.18"
control_abbrev = "gke"

gke_clusters = get_gke_clusters(gcp_project_id, gcp_gke_locations)

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure Kubernetes Clusters created with limited service account Access scopes for Project access"

  desc "Access scopes are the legacy method of specifying permissions for your instance. Before the existence of IAM roles, access scopes were the only mechanism for granting permissions to service accounts. By default, your node service account has access scopes."
  desc "rationale", "If you are not creating a separate service account for your nodes, you should limit the scopes of the node service account to reduce the possibility of a privilege escalation in an attack. This ensures that your default service account does not have permissions beyond those necessary to run your cluster. While the default scopes are limited, they may include scopes beyond the minimally required scopes needed to run your cluster."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/compute/docs/access/service-accounts#the_default_service_account"

  # Checking for the default oauth scopes and not certain privileged scopes
  gke_clusters.each do |gke_cluster|
    google_container_regional_node_pools(project: gcp_project_id, location: gke_cluster[:location], cluster: gke_cluster[:cluster_name]).names.each do |nodepoolname|
      describe "[#{gcp_project_id}] Cluster #{gke_cluster[:location]}/#{gke_cluster[:cluster_name]}/#{nodepoolname}" do
        subject { google_container_regional_node_pool(project: gcp_project_id, location: gke_cluster[:location], cluster: gke_cluster[:cluster_name], name: nodepoolname) }
        its('config.oauth_scopes') { should_not include /cloud-platform/ }
        its('config.oauth_scopes') { should_not include /compute/ }
        its('config.oauth_scopes') { should_not include /compute-ro/ }
        its('config.oauth_scopes') { should_not include /compute-rw/ }
        its('config.oauth_scopes') { should_not include /container/ }
        its('config.oauth_scopes') { should_not include /iam/ }
        its('config.oauth_scopes') { should include /devstorage.read_only/ }
        its('config.oauth_scopes') { should include /logging.write/ }
        its('config.oauth_scopes') { should include /monitoring/ }
        its('config.oauth_scopes') { should include /service.management.readonly/ }
        its('config.oauth_scopes') { should include /servicecontrol/ }
        its('config.oauth_scopes') { should include /trace.append/ }
      end
    end
  end

end
