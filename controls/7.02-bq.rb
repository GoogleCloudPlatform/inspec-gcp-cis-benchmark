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

title 'Ensure that all BigQuery tables are encrypted with customer-managed encryption key (CMEK)'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '7.2'
control_abbrev = 'storage'

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'high'

  title "[#{control_abbrev.upcase}] Ensure that all BigQuery tables are encrypted with customer-managed encryption key (CMEK)"

  desc 'BigQuery by default encrypts the data as rest by employing Envelope Encryption using Google managed cryptographic keys.
  The data is encrypted using the data encryption keys and data encryption keys themselves are further encrypted using key
  encryption keys. This is seamless and do not require any additional input from the user. However, if you want to have greater
  control, Customer-managed encryption keys (CMEK) can be used as encryption key management solution for BigQuery Data Sets.
  If CMEK is used, the CMEK is used to encrypt the data encryption keys instead of using google-managed encryption keys.'
  desc 'rationale', 'BigQuery by default encrypts the data as rest by employing Envelope Encryption using Google managed
  cryptographic keys. This is seamless and does not require any additional input from the user. For greater control over
  the encryption, customer-managed encryption keys (CMEK) can be used as encryption key management solution for BigQuery tables.
  The CMEK is used to encrypt the data encryption keys instead of using google-managed encryption keys. BigQuery stores the
  table and CMEK association and the encryption/decryption is done automatically. Applying the Default Customer-managed keys on
  BigQuery data sets ensures that all the new tables created in the future will be encrypted using CMEK but existing tables need
  to be updated to use CMEK individually.'

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
    google_bigquery_datasets(project: gcp_project_id).ids.each do |dataset_name|
      google_bigquery_tables(project: gcp_project_id, dataset: dataset_name.split(':').last).table_references.each do |table_reference|
        describe "[#{gcp_project_id}] BigQuery Table #{table_reference.table_id} should use customer-managed encryption keys (CMEK)" do
          subject { google_bigquery_table(project: gcp_project_id, dataset: dataset_name.split(':').last, name: table_reference.table_id).encryption_configuration }
          its('kms_key_name') { should_not eq nil }
        end
      end
    end
  end
end
