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

title 'Ensure that Separation of duties is enforced while assigning KMS related roles to users'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = '1.11'
control_abbrev = 'iam'

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'medium'

  title "[#{control_abbrev.upcase}] Ensure that Separation of duties is enforced while assigning KMS related roles to users"

  desc "It is recommended that the principle of 'Separation of Duties' is enforced while assigning KMS related roles to users."

  desc 'rationale', "Built-in/Predefined IAM role Cloud KMS Admin allows user/identity to create, delete, and manage service account(s). Built-in/Predefined IAM role Cloud KMS CryptoKey Encrypter/Decrypter allows user/identity (with adequate privileges on concerned resources) to encrypt and decrypt data at rest using encryption key(s). Built-in/Predefined IAM role Cloud KMS CryptoKey Encrypter allows user/identity (with adequate privileges on concerned resources) to encrypt data at rest using encryption key(s). Builtin/Predefined IAM role Cloud KMS CryptoKey Decrypter allows user/identity (with adequate privileges on concerned resources) to decrypt data at rest using encryption key(s).

Separation of duties is the concept of ensuring that one individual does not have all necessary permissions to be able to complete a malicious action. In Cloud KMS, this could be an action such as using a key to access and decrypt data that that user should not normally have access to. Separation of duties is a business control typically used in larger organizations, meant to help avoid security or privacy incidents and errors. It is considered best practice.

Any user(s) should not have Cloud KMS Admin and any of the Cloud KMS CryptoKey Encrypter/Decrypter, Cloud KMS CryptoKey Encrypter, Cloud KMS CryptoKey Decrypter roles assigned at a time."

  tag cis_scored: true
  tag cis_level: 2
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/kms/docs/separation-of-duties'

  kms_admins = google_project_iam_binding(project: gcp_project_id, role: 'roles/cloudkms.admin')

  if kms_admins.members.count == 0
    impact 'none'
    describe "[#{gcp_project_id}] does not have users with roles/CloudKMSAdmin. This test is Not Applicable." do
      skip "[#{gcp_project_id}] does not have users with roles/CloudKMSAdmin"
    end
  else
    describe "[#{gcp_project_id}] roles/cloudkms.cryptoKeyEncrypter" do
      subject { google_project_iam_binding(project: gcp_project_id, role: 'roles/cloudkms.cryptoKeyEncrypter') }
      kms_admins.members.each do |kms_admin|
        its('members.to_s') { should_not match kms_admin }
      end
    end
    describe "[#{gcp_project_id}] roles/cloudkms.cryptoKeyDecrypter" do
      subject { google_project_iam_binding(project: gcp_project_id, role: 'roles/cloudkms.cryptoKeyDecrypter') }
      kms_admins.members.each do |kms_admin|
        its('members.to_s') { should_not match kms_admin }
      end
    end
    describe "[#{gcp_project_id}] roles/cloudkms.cryptoKeyEncrypterDecrypter" do
      subject { google_project_iam_binding(project: gcp_project_id, role: 'roles/cloudkms.cryptoKeyEncrypterDecrypter') }
      kms_admins.members.each do |kms_admin|
        its('members.to_s') { should_not match kms_admin }
      end
    end
  end
end
