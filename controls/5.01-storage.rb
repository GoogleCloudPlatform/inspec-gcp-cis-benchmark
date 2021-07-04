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

title 'Ensure that Cloud Storage bucket is not anonymously or publicly accessible'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '5.1'
control_abbrev = 'storage'

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'high'

  title "[#{control_abbrev.upcase}] Ensure that Cloud Storage bucket is not anonymously or publicly accessible"

  desc 'It is recommended that IAM policy on Cloud Storage bucket does not allows anonymous and/or public access.'
  desc 'rationale', 'Allowing anonymous and/or public access grants permissions to anyone to access bucket content. Such access might not be desired if you are storing any sensitive data. Hence, ensure that anonymous and/or public access to a bucket is not allowed.'

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ["AC-2", "CA-3"]

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/storage/docs/access-control/iam-reference'
  ref 'GCP Docs', url: 'https://cloud.google.com/storage/docs/access-control/making-data-public'

  google_storage_buckets(project: gcp_project_id).bucket_names.each do |bucket|
    google_storage_bucket_iam_bindings(bucket: bucket).iam_binding_roles.each do |role|
      describe "[#{gcp_project_id}] GCS Bucket #{bucket}, Role: #{role}" do
        subject { google_storage_bucket_iam_binding(bucket: bucket, role: role) }
        its('members') { should_not include 'allUsers' }
        its('members') { should_not include 'allAuthenticatedUsers' }
      end
    end
  end
end
