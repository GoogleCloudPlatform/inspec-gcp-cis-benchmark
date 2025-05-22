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
  desc 'Dataproc clusters should be encrypted with customer-managed encryption keys (CMEK).'
  desc 'rationale', 'Using CMEK for Dataproc cluster encryption allows for greater control over key management and encryption settings, enhancing security.'

  tag cis_scored: true
  tag cis_level: 2
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['SC-28']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/docs/security/encryption/default-encryption'

  google_dataproc_clusters(project: gcp_project_id).cluster_names.each do |cluster_name|
    cluster = google_dataproc_cluster(project: gcp_project_id, name: cluster_name)

    describe "[#{gcp_project_id}] Dataproc Cluster: #{cluster_name}" do
      subject { cluster }
      its('encryption_config.gce_pd_kms_key_name') { should_not be_nil }
      its('encryption_config.gce_pd_kms_key_name') { should_not be_empty }
    end
  end
end