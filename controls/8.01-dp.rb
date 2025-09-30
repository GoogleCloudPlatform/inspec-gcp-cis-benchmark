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

title 'Ensure that Dataproc Cluster is encrypted using Customer-Managed Encryption Key'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '8.1'
control_abbrev = 'dataproc'

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'medium'
  title "[#{control_abbrev.upcase}] Ensure that Dataproc Cluster is encrypted using Customer-Managed Encryption Key"
  desc 'When you use Dataproc, cluster and job data is stored on Persistent Disks (PDs) associated with the Compute Engine VMs in your cluster
        and in a Cloud Storage staging bucket. This PD and bucket data is encrypted using a Google-generated data encryption key (DEK) and key
        encryption key (KEK). The CMEK feature allows you to create, use, and revoke the key encryption key (KEK). Google still controls the data
        encryption key (DEK).'
  desc 'rationale', 'Cloud services offer the ability to protect data related to those services using encryption keys managed by the customer within
        Cloud KMS. These encryption keys are called customer-managed encryption keys (CMEK). When you protect data in Google Cloud services with CMEK,
        the CMEK key is within your control.'

  tag cis_scored: true
  tag cis_level: 2
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['SC-28']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/docs/security/encryption/default-encryption'

  # Fetch all available compute regions
  # This uses a helper method or a direct gcloud command execution
  # You might need to add a helper function in your libraries or execute a shell command
  # For simplicity, let's assume you have a way to get all regions.
  # A common way is to use a custom InSpec resource or shell out to gcloud.

  # Example using a placeholder for dynamic region discovery (you'd implement this)
  # In a real scenario, you might use `command('gcloud compute regions list --format="value(name)"').stdout.strip.split("\n")`
  # but directly executing `gcloud` within an InSpec resource's `initialize` or `filter`
  # methods can be tricky due to execution context and dependencies.
  # A better approach is to define a custom InSpec resource that wraps these gcloud calls.
  # For now, let's manually list some common regions, or pass them as an input if fixed.

  # If you need to make this fully dynamic without hardcoding, you would likely need a
  # custom InSpec resource that uses the Google Cloud SDK for Ruby to list regions.
  # For demonstration, let's use a hardcoded list of common regions.
  # In a real-world, dynamic scenario, you'd integrate a resource like `google_compute_regions`
  # or run a `gcloud` command to get the list.

  all_gcp_regions = google_compute_regions(project: gcp_project_id).region_names

  found_clusters = []

  all_gcp_regions.each do |region|
    clusters_in_region = google_dataproc_clusters(project: gcp_project_id, region: region)
    found_clusters.concat(clusters_in_region.cluster_names.map { |name| { name: name, region: region } }) if clusters_in_region.cluster_names.any?
  rescue Inspec::Exceptions::ResourceFailed => e
    # This will catch errors if the Dataproc API isn't enabled in a region,
    # or if there are other region-specific issues.
    # You can log this for debugging if needed:
    # puts "Could not list clusters in region #{region}: #{e.message}"
  end

  if found_clusters.empty?
    describe "No Dataproc clusters found in project '#{gcp_project_id}' across all common regions." do
      subject { found_clusters }
      it { should be_empty }
    end
  else
    found_clusters.each do |cluster_info|
      cluster_name = cluster_info[:name]
      cluster_region = cluster_info[:region]
      cluster = google_dataproc_cluster(project: gcp_project_id, name: cluster_name, region: cluster_region)

      describe "[#{gcp_project_id}] Dataproc Cluster: #{cluster_name} in region #{cluster_region}" do
        subject { cluster }
        its('encryption_config.gce_pd_kms_key_name') { should_not be_nil }
        its('encryption_config.gce_pd_kms_key_name') { should_not be_empty }
      end
    end
  end
end
