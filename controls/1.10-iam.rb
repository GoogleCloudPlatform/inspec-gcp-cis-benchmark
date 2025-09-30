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

title 'Ensure KMS Encryption Keys Are Rotated Within a Period of 90 Days'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '1.10'
control_abbrev = 'iam'
kms_rotation_period_seconds = input('kms_rotation_period_seconds')

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'none'

  title "[#{control_abbrev.upcase}] Ensure KMS Encryption Keys Are Rotated Within a Period of 90 Days"

  desc "Google Cloud Key Management Service stores cryptographic keys in a hierarchical structure designed for useful and elegant access control management.

  The format for the rotation schedule depends on the client library that is used. For the gcloud command-line tool, the next rotation time must be in ISO or RFC3339 format, and the rotation period must be in the form INTEGER[UNIT], where units can be one of seconds (s), minutes (m), hours (h) or days (d)."

  desc 'rationale', "Set a key rotation period and starting time. A key can be created with a specified rotation period, which is the time between when new key versions are generated automatically. A key can also be created with a specified next rotation time. A key is a named object representing a cryptographic key used for a specific purpose. The key material, the actual bits used for encryption, can change over time as new key versions are created.

  A key is used to protect some corpus of data. A collection of files could be encrypted with the same key and people with decrypt permissions on that key would be able to decrypt those files. Therefore, it's necessary to make sure the rotation period is set to a specific time."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['AC-2']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/kms/docs/key-rotation#frequency_of_key_rotation'
  ref 'GCP Docs', url: 'https://cloud.google.com/kms/docs/re-encrypt-data'

  # Get all "normal" regions and add dual/multi regions
  locations = google_compute_regions(project: gcp_project_id).region_names
  locations << 'global' << 'asia' << 'europe' << 'us' << 'eur4' << 'nam4'

  kms_cache = KMSKeyCache(project: gcp_project_id, locations: locations)

  # Ensure KMS keys autorotate 90d or less
  locations.each do |location|
    if kms_cache.kms_key_ring_names[location].empty?
      describe "[#{gcp_project_id}] does not contain any key rings in [#{location}]. This test is Not Applicable." do
        skip "[#{gcp_project_id}] does not contain any key rings in [#{location}]"
      end
    else
      kms_cache.kms_key_ring_names[location].each do |keyring|
        if kms_cache.kms_crypto_keys[location][keyring].empty?
          describe "[#{gcp_project_id}] key ring [#{keyring}] does not contain any cryptographic keys. This test is Not Applicable." do
            skip "[#{gcp_project_id}] key ring [#{keyring}] does not contain any cryptographic keys"
          end
        else
          kms_cache.kms_crypto_keys[location][keyring].each do |keyname|
            key = google_kms_crypto_key(project: gcp_project_id, location: location, key_ring_name: keyring, name: keyname)
            next unless key.purpose == 'ENCRYPT_DECRYPT' && key.primary_state == 'ENABLED'
            impact 'medium'
            describe "[#{gcp_project_id}] #{key.crypto_key_name}" do
              subject { key }
              its('rotation_period') { should_not eq nil }
              unless key.rotation_period.nil?
                rotation_period_int = key.rotation_period.delete_suffix('s').to_i
                it "should have a lower or equal rotation period than #{kms_rotation_period_seconds}" do
                  expect(rotation_period_int).to be <= kms_rotation_period_seconds
                end
                its('next_rotation_time') { should be <= (Time.now + kms_rotation_period_seconds) }
              end
            end
          end
        end
      end
    end
  end
end
