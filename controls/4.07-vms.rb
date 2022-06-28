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

title 'Ensure VM disks for critical VMs are encrypted with CustomerSupplied Encryption Keys (CSEK)'

gcp_project_id = input('gcp_project_id')
gce_zones = input('gce_zones')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '4.7'
control_abbrev = 'vms'

gce_instances = GCECache(project: gcp_project_id, gce_zones: gce_zones).gce_instances_cache

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'medium'

  title "[#{control_abbrev.upcase}] Ensure VM disks for critical VMs are encrypted with CustomerSupplied Encryption Keys (CSEK)"

  desc 'Customer-Supplied Encryption Keys (CSEK) are a feature in Google Cloud Storage and Google Compute Engine. If you supply your own encryption keys, Google uses your key to protect the Google-generated keys used to encrypt and decrypt your data. By default, Google Compute Engine encrypts all data at rest. Compute Engine handles and manages this encryption for you without any additional actions on your part. However, if you wanted to control and manage this encryption yourself, you can provide your own encryption keys.'
  desc 'rationale', "By default, Google Compute Engine encrypts all data at rest. Compute Engine handles and manages this encryption for you without any additional actions on your part. However, if you wanted to control and manage this encryption yourself, you can provide your own encryption keys.

If you provide your own encryption keys, Compute Engine uses your key to protect the Google-generated keys used to encrypt and decrypt your data. Only users who can provide the correct key can use resources protected by a customer-supplied encryption key.

Google does not store your keys on its servers and cannot access your protected data unless you provide the key. This also means that if you forget or lose your key, there is no way for Google to recover the key or to recover any data encrypted with the lost key.

At least business critical VMs should have VM disks encrypted with CSEK."

  tag cis_scored: true
  tag cis_level: 2
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['SC-1']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/compute/docs/disks/customer-supplied-encryption#encrypt_a_new_persistent_disk_with_your_own_keys'
  ref 'GCP Docs', url: 'https://cloud.google.com/compute/docs/reference/rest/v1/disks/get'
  ref 'GCP Docs', url: 'https://cloud.google.com/compute/docs/disks/customer-supplied-encryption#key_file'

  gce_instances.each do |instance|
    next if instance[:name] =~ /^gke-/
    describe "[#{gcp_project_id}] Instance #{instance[:zone]}/#{instance[:name]}" do
      subject { google_compute_instance(project: gcp_project_id, zone: instance[:zone], name: instance[:name]) }
      it { should have_disks_encrypted_with_csek }
    end
  end

  if gce_instances.empty?
    impact 'none'
    describe "[#{gcp_project_id}] No Google Compute Engine instances were found. This test is Not Applicable." do
      skip "[#{gcp_project_id}] No Google Compute Engine instances were found"
    end
  end
end
