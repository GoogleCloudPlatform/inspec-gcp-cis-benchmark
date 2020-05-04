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

title 'Ensure user-managed/external keys for service accounts are rotated every 90 days or less'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "1.7"
control_abbrev = "iam"
sa_key_older_than_seconds = attribute('sa_key_older_than_seconds')

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure user-managed/external keys for service accounts are rotated every 90 days or less"

  desc "Service Account keys consist of a key ID (Private_key_Id) and Private key, which are used to sign programmatic requests that you make to Google cloud services accessible to that particular Service account. It is recommended that all Service Account keys are regularly rotated."
  desc "rationale", "Rotating Service Account keys will reduce the window of opportunity for an access key that is associated with a compromised or terminated account to be used. Service Account keys should be rotated to ensure that data cannot be accessed with an old key which might have been lost, cracked, or stolen.

Each service account is associated with a key pair, which is managed by Google Cloud Platform (GCP). It is used for service-to-service authentication within GCP. Google rotates the keys daily.

GCP provides option to create one or more user-managed (also called as external key pairs) key pairs for use from outside GCP (for example, for use with Application Default Credentials). When a new key pair is created, user is enforced download the private key (which is not retained by Google). With external keys, users are responsible for security of the private key and other management operations such as key rotation. External keys can be managed by the IAM API, gcloud command-line tool, or the Service Accounts page in the Google Cloud Platform Console. GCP facilitates up to 10 external service account keys per service account to facilitate key rotation."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/iam/docs/understanding-service-accounts#managing_service_account_keys"
  ref "GCP Docs", url: "https://cloud.google.com/sdk/gcloud/reference/iam/service-accounts/keys/list"
  ref "GCP Docs", url: "https://cloud.google.com/iam/docs/service-accounts"

  google_service_accounts(project: gcp_project_id).service_account_emails.each do |sa_email|
    if google_service_account_keys(project: gcp_project_id, service_account: sa_email).key_names.count > 1
      describe "[#{gcp_project_id}] ServiceAccount Keys for #{sa_email} older than #{sa_key_older_than_seconds} seconds" do
        subject { google_service_account_keys(project: gcp_project_id, service_account: sa_email).where { (Time.now - sa_key_older_than_seconds > valid_after_time) } }
        it { should_not exist }
      end
    end
  end

end
