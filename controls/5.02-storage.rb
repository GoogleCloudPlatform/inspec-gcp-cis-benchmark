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

title 'Ensure that Cloud Storage buckets have uniform bucket-level access enabled'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "5.2"
control_abbrev = "storage"

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure that Cloud Storage buckets have uniform bucket-level access enabled"

  desc "It is recommended that uniform bucket-level access is enabled on Cloud Storage buckets."
  desc "rationale", "It is recommended to use uniform bucket-level access to unify and simplify how you grant
access to your Cloud Storage resources.
Cloud Storage offers two systems for granting users permission to access your buckets and
objects: Cloud Identity and Access Management (Cloud IAM) and Access Control Lists
(ACLs). These systems act in parallel - in order for a user to access a Cloud Storage
resource, only one of the systems needs to grant the user permission. Cloud IAM is used
throughout Google Cloud and allows you to grant a variety of permissions at the bucket and
project levels. ACLs are used only by Cloud Storage and have limited permission options,
but they allow you to grant permissions on a per-object basis.

In order to support a uniform permissioning system, Cloud Storage has uniform bucket-
level access. Using this feature disables ACLs for all Cloud Storage resources: access to

Cloud Storage resources then is granted exclusively through Cloud IAM. Enabling uniform
bucket-level access guarantees that if a Storage bucket is not publicly accessible, no object
in the bucket is publicly accessible either."

  tag cis_scored: false
  tag cis_level: 1
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/storage/docs/uniform-bucket-level-access"

  google_storage_buckets(project: gcp_project_id).bucket_names.each do |bucket|
    uniform_bucket_level_access = google_storage_bucket(name: bucket).acl.nil?
    describe "[#{gcp_project_id}] GCS Bucket #{bucket}" do
      it 'should have uniform bucket-level access enabled' do
        expect(uniform_bucket_level_access).to be true
      end
    end
  end
end
