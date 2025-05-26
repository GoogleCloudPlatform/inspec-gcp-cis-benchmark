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

title 'Ensure that a default customer-managed encryption key (CMEK) is specified for all BigQuery data sets'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '7.3'
control_abbrev = 'storage'

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'high'

  title "[#{control_abbrev.upcase}] Ensure that a default customer-managed encryption key (CMEK) is specified for all BigQuery data sets"

  desc 'BigQuery by default encrypts the data as rest by employing Envelope Encryption using Google managed cryptographic keys. The data
  is encrypted using the data encryption keys and data encryption keys themselves are further encrypted using key encryption keys. This is
  seamless and do not require any additional input from the user. However, if you want to have greater control, Customer-managed encryption
  keys (CMEK) can be used as encryption key management solution for BigQuery Data Sets.'
  desc 'rationale', 'BigQuery by default encrypts the data as rest by employing Envelope Encryption using Google managed cryptographic keys.
  This is seamless and does not require any additional input from the user.
  For greater control over the encryption, customer-managed encryption keys (CMEK) can be used as encryption key management solution for
  BigQuery Data Sets. Setting a Default Customer-managed encryption key (CMEK) for a data set ensure any tables created in future will use
  the specified CMEK if none other is provided.'

  tag cis_scored: true
  tag cis_level: 2
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['SC-1']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/bigquery/docs/customer-managed-encryption'

  if google_bigquery_datasets(project: gcp_project_id).ids.empty?
    impact 'none'
    describe "[#{gcp_project_id}] does not have BigQuery Datasets, this test is Not Applicable." do
      skip "[#{gcp_project_id}] does not have BigQuery Datasets"
    end
  else
    google_bigquery_datasets(project: gcp_project_id).ids.each do |name|
      describe "[#{gcp_project_id}] BigQuery Dataset #{name} should use customer-managed encryption keys (CMEK)" do
        subject { google_bigquery_dataset(project: gcp_project_id, name: name.split(':').last).default_encryption_configuration }
        its('kms_key_name') { should_not eq nil }
      end
    end
  end
end
