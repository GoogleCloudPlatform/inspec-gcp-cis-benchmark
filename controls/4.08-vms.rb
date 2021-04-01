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

title 'Ensure Compute instances are launched with Shielded VM enabled'

gcp_project_id = input('gcp_project_id')
gce_zones = input('gce_zones')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '4.8'
control_abbrev = 'vms'

gce_instances = GCECache(project: gcp_project_id, gce_zones: gce_zones).gce_instances_cache

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'medium'

  title "[#{control_abbrev.upcase}] Ensure Compute instances are launched with Shielded VM enabled"

  desc 'To defend against against advanced threats and ensure that the boot loader and firmware
  on your VMs are signed and untampered, it is recommended that Compute instances are
  launched with Shielded VM enabled.'
  desc 'rationale', "Shielded VMs are virtual machines (VMs) on Google Cloud Platform hardened by a set of
  security controls that help defend against rootkits and bootkits.
  Shielded VM offers verifiable integrity of your Compute Engine VM instances, so you can be
  confident your instances haven't been compromised by boot- or kernel-level malware or
  rootkits. Shielded VM's verifiable integrity is achieved through the use of Secure Boot,
  virtual trusted platform module (vTPM)-enabled Measured Boot, and integrity monitoring.
  Shielded VM instances run firmware which is signed and verified using Google's Certificate
  Authority, ensuring that the instance's firmware is unmodified and establishing the root of
  trust for Secure Boot.
  Integrity monitoring helps you understand and make decisions about the state of your VM
  instances and the Shielded VM vTPM enables Measured Boot by performing the
  measurements needed to create a known good boot baseline, called the integrity policy
  baseline. The integrity policy baseline is used for comparison with measurements from
  subsequent VM boots to determine if anything has changed.
  Secure Boot helps ensure that the system only runs authentic software by verifying the
  digital signature of all boot components, and halting the boot process if signature
  verification fails."

  tag cis_scored: true
  tag cis_level: 2
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/compute/docs/instances/modifying-shielded-vm'
  ref 'GCP Docs', url: 'https://cloud.google.com/shielded-vm'
  ref 'GCP Docs', url: 'https://cloud.google.com/security/shielded-cloud/shielded-vm#organization-policy-constraint'

  gce_instances.each do |instance|
    instance_object = google_compute_instance(project: gcp_project_id, zone: instance[:zone], name: instance[:name])
    describe "[#{gcp_project_id}] Instance #{instance[:zone]}/#{instance[:name]}" do
      if instance_object.shielded_instance_config.nil?
        it 'should have a shielded instance config' do
          expect(false).to be true
        end
      else
        it 'should have secure boot enabled' do
          expect(instance_object.shielded_instance_config.enable_secure_boot).to be true
        end
        it 'should have integrity monitoring enabled' do
          expect(instance_object.shielded_instance_config.enable_integrity_monitoring).to be true
        end
        it 'should have virtual trusted platform module (vTPM) enabled' do
          expect(instance_object.shielded_instance_config.enable_vtpm).to be true
        end
      end
    end
  end
end
