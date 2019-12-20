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

title 'Ensure Container-Optimized OS (cos) is used for Kubernetes Engine Clusters Node image'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "7.9"
control_abbrev = "gke"

gke_clusters = get_gke_clusters(gcp_project_id)

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure Container-Optimized OS (cos) is used for Kubernetes Engine Clusters Node image"

  desc "Container-Optimized OS is an operating system image for your Compute Engine VMs that is optimized for running Docker containers. With Container-Optimized OS, you can bring up your Docker containers on Google Cloud Platform quickly, efficiently, and securely"
  desc "rationale", "The Container-Optimized OS node image is based on a recent version of the Linux kernel and is optimized to enhance node security. It is backed by a team at Google that can quickly patch it for security and iterate on features. The Container-Optimized OS image provides better support, security, and stability than previous images. Container-Optimized OS requires Kubernetes version 1.4.0 or higher.

Enabling Container-Optimized OS provides the following benefits:

- Run Containers Out of the Box: Container-Optimized OS instances come preinstalled with the Docker runtime and cloud-init. With a Container-Optimized OS instance, you can bring up your Docker container at the same time you create your VM, with no on-host setup required.
- Smaller attack surface: Container-Optimized OS has a smaller footprint, reducing your instance's potential attack surface.
- Locked-down by default: Container-Optimized OS instances include a locked-down firewall and other security settings by default.
- Automatic Updates: Container-Optimized OS instances are configured to automatically download weekly updates in the background; only a reboot is necessary to use the latest updates."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/kubernetes-engine/docs/concepts/node-images"
  ref "GCP Docs", url: "https://cloud.google.com/container-optimized-os/docs/"

  gke_clusters.each do |gke_cluster|
    google_container_regional_node_pools(project: gcp_project_id, location: gke_cluster[:location], cluster: gke_cluster[:cluster_name]).names.each do |nodepoolname|
      describe "[#{gcp_project_id}] Cluster #{gke_cluster[:location]}/#{gke_cluster[:cluster_name]}, Node Pool: #{nodepoolname}" do
        subject { google_container_regional_node_pool(project: gcp_project_id, location: gke_cluster[:location], cluster: gke_cluster[:cluster_name], name: nodepoolname) }
        its('config.image_type') { should match /COS/ }
      end
    end
  end

end
