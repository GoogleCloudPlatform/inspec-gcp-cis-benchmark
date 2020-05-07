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

title 'Ensure that Cloud KMS cryptokeys are not anonymously or publicly accessible'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = '1.9'
control_abbrev = 'iam'

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure that Cloud KMS cryptokeys are not anonymously or publicly accessible"

  desc 'It is recommended that the IAM policy on Cloud KMS cryptokeys should restrict anonymous and/or public access.'

  desc 'rationale', "Granting permissions to allUsers or allAuthenticatedUsers allows anyone to access the dataset. Such access might not be desirable if sensitive data is stored at the location. In this case, ensure that anonymous and/or public access to a Cloud KMS cryptokey is not allowed."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/kms/docs/key-rotation#frequency_of_key_rotation"

  # Get all "normal" regions and add "global"
  locations = google_compute_regions(project: gcp_project_id).region_names
  locations << 'global'

  # Ensure that keys aren't publicly accessible
  locations.each do |location|
    if google_kms_key_rings(project: gcp_project_id, location: location).key_ring_names.empty?
      impact 0
      describe "[#{gcp_project_id}] does not contain any key rings in [#{location}]. This test is Not Applicable." do
        skip "[#{gcp_project_id}] does not contain any key rings in [#{location}]"
      end
    else
      google_kms_key_rings(project: gcp_project_id, location: location).key_ring_names.each do |keyring|
        if google_kms_crypto_keys(project: gcp_project_id, location: location, key_ring_name: keyring).crypto_key_names.empty?
          impact 0
          describe "[#{gcp_project_id}] key ring [#{keyring}] does not contain any cryptographic keys. This test is Not Applicable." do
            skip "[#{gcp_project_id}] key ring [#{keyring}] does not contain any cryptographic keys"
          end
        else
          google_kms_crypto_keys(project: gcp_project_id, location: location, key_ring_name: keyring).crypto_key_names.each do |keyname|
            if google_kms_crypto_key_iam_policy(project: gcp_project_id, location: location, key_ring_name: keyring, crypto_key_name: keyname).bindings.nil?
              impact 0
              describe "[#{gcp_project_id}] key ring [#{keyring}] key [#{keyname}] does not have any IAM bindings. This test is Not Applicable." do
                skip "[#{gcp_project_id}] key ring [#{keyring}] key [#{keyname}] does not have any IAM bindings"
              end              
            else
              impact 1.0
              google_kms_crypto_key_iam_policy(project: gcp_project_id, location: location, key_ring_name: keyring, crypto_key_name: keyname).bindings.each do |binding|
                describe binding do
                  its('members') { should_not include 'allUsers'}
                  its('members') { should_not include 'allAuthenticatedUsers'}
                end
              end
            end
          end          
        end
      end      
    end
  end
end
