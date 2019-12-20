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

title 'Ensure Stackdriver Logging is set to Enabled on Kubernetes Engine Clusters'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "7.1"
control_abbrev = "gke"

gke_clusters = get_gke_clusters(gcp_project_id)

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure Stackdriver Logging is set to Enabled on Kubernetes Engine Clusters"

  desc "Stackdriver Logging is part of the Stackdriver suite of products in Google Cloud Platform. It includes storage for logs, a user interface called the Logs Viewer, and an API to manage logs programmatically. Stackdriver Logging lets you have Kubernetes Engine automatically collect, process, and store your container and system logs in a dedicated, persistent datastore. Container logs are collected from your containers. System logs are collected from the cluster's components, such as docker and kubelet. Events are logs about activity in the cluster, such as the scheduling of Pods."
  desc "rationale", "By Enabling you will have container and system logs, Kubernetes Engine deploys a pernode logging agent that reads container logs, adds helpful metadata, and then stores them.  The logging agent checks for container logs in the following sources:

- Standard output and standard error logs from containerized processes
- kubelet and container runtime logs
- Logs for system components, such as VM startup scripts

For events, Kubernetes Engine uses a Deployment in the kube-system namespace which automatically collects events and sends them to Stackdriver Logging.

Stackdriver Logging is compatible with JSON and glog formats. Logs are stored for up to 30
days."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/kubernetes-engine/docs/how-to/creating-a-container-cluster"
  ref "GCP Docs", url: "https://cloud.google.com/kubernetes-engine/docs/how-to/logging"
  ref "GCP Docs", url: "https://cloud.google.com/logging/docs/basic-concepts"

  gke_clusters.each do |gke_cluster|
    describe "[#{gcp_project_id}] Cluster #{gke_cluster[:location]}/#{gke_cluster[:cluster_name]}" do
      subject { google_container_regional_cluster(project: gcp_project_id, location: gke_cluster[:location], name: gke_cluster[:cluster_name]) }
      its('logging_service') { should match /^logging.googleapis.com/ }
    end
  end

end
