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

title 'Ensure user-managed/external keys for service accounts are rotated every 90 days or less'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '1.7'
control_abbrev = 'iam'
sa_key_older_than_seconds = input('sa_key_older_than_seconds')

service_account_cache = ServiceAccountCache(project: gcp_project_id)

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'none'

  title "[#{control_abbrev.upcase}] Ensure user-managed/external keys for service accounts are rotated every 90 days or less"

  desc 'Service Account keys consist of a key ID (Private_key_Id) and Private key, which are used to sign programmatic requests users make to Google cloud services accessible to that particular service account. It is recommended that all Service Account keys are regularly rotated.'
  desc 'rationale', "Rotating Service Account keys will reduce the window of opportunity for an access key that is associated with a compromised or terminated account to be used. Service Account keys should be rotated to ensure that data cannot be accessed with an old key that might have been lost, cracked, or stolen.

  Each service account is associated with a key pair managed by Google Cloud Platform (GCP). It is used for service-to-service authentication within GCP. Google rotates the keys daily.

  GCP provides the option to create one or more user-managed (also called external key pairs) key pairs for use from outside GCP (for example, for use with Application Default Credentials). When a new key pair is created, the user is required to download the private key (which is not retained by Google). With external keys, users are responsible for keeping the private key secure and other management operations such as key rotation. External keys can be managed by the IAM API, gcloud command-line tool, or the Service Accounts page in the Google Cloud Platform Console. GCP facilitates up to 10 external service account keys per service account to facilitate key rotation."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['AC-2']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/iam/docs/understanding-service-accounts#managing_service_account_keys'
  ref 'GCP Docs', url: 'https://cloud.google.com/sdk/gcloud/reference/iam/service-accounts/keys/list'
  ref 'GCP Docs', url: 'https://cloud.google.com/iam/docs/service-accounts'

  service_account_cache.service_account_emails.each do |sa_email|
    if service_account_cache.service_account_keys[sa_email].key_names.count > 1
      impact 'medium'
      describe "[#{gcp_project_id}] ServiceAccount Keys for #{sa_email} older than #{sa_key_older_than_seconds} seconds" do
        subject { service_account_cache.service_account_keys[sa_email].where { (Time.now - sa_key_older_than_seconds > valid_after_time) } }
        it { should_not exist }
      end
    else
      describe "[#{gcp_project_id}] ServiceAccount [#{sa_email}] does not have user-managed keys. This test is Not Applicable." do
        skip "[#{gcp_project_id}] ServiceAccount [#{sa_email}] does not have user-managed keys."
      end
    end
  end
end
