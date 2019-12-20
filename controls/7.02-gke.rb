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

title 'Ensure Stackdriver Monitoring is set to Enabled on Kubernetes Engine Clusters'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "7.2"
control_abbrev = "gke"

gke_clusters = get_gke_clusters(gcp_project_id)

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure Stackdriver Monitoring is set to Enabled on Kubernetes Engine Clusters"

  desc "Stackdriver Monitoring to monitor signals and build operations in your Kubernetes Engine clusters. Stackdriver Monitoring can access metrics about CPU utilization, some disk traffic metrics, network traffic, and uptime information. Stackdriver Monitoring uses the Monitoring agent to access additional system resources and application services in virtual machine instances."
  desc "rationale", "By Enabling Stackdriver Monitoring you will have system metrics and custom metrics.  System metrics are measurements of the cluster's infrastructure, such as CPU or memory usage. For system metrics, Stackdriver creates a Deployment that periodically connects to each node and collects metrics about its Pods and containers, then sends the metrics to Stackdriver. Metrics for usage of system resources are collected from the CPU, Memory, Evictable memory, Non-evictable memory, and Disk sources."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/kubernetes-engine/docs/how-to/creating-a-container-cluster"
  ref "GCP Docs", url: "https://cloud.google.com/kubernetes-engine/docs/how-to/monitoring"
  ref "GCP Docs", url: "https://cloud.google.com/monitoring/agent/"

  gke_clusters.each do |gke_cluster|
    describe "[#{gcp_project_id}] Cluster #{gke_cluster[:location]}/#{gke_cluster[:cluster_name]}" do
      subject { google_container_regional_cluster(project: gcp_project_id, location: gke_cluster[:location], name: gke_cluster[:cluster_name]) }
      its('monitoring_service') { should match /^monitoring.googleapis.com/ }
    end
  end

end
