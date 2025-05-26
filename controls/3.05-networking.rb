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

title 'Ensure That RSASHA1 Is Not Used for the Zone-Signing Key in Cloud DNS DNSSEC'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '3.5'
control_abbrev = 'networking'

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'none'

  title "[#{control_abbrev.upcase}] Ensure That RSASHA1 Is Not Used for the Zone-Signing Key in Cloud DNS DNSSEC"

  desc 'NOTE: Currently, the SHA1 algorithm has been removed from general use by Google, and, if being used, needs to be whitelisted on a project basis by Google and will also, therefore, require a Google Cloud support contract.

  DNSSEC algorithm numbers in this registry may be used in CERT RRs. Zone signing (DNSSEC) and transaction security mechanisms (SIG(0) and TSIG) make use of particular subsets of these algorithms. The algorithm used for key signing should be a recommended one and it should be strong.'
  desc 'rationale', "DNSSEC algorithm numbers in this registry may be used in CERT RRs. Zone signing (DNSSEC) and transaction security mechanisms (SIG(0) and TSIG) make use of particular subsets of these algorithms.

  The algorithm used for key signing should be a recommended one and it should be strong. When enabling DNSSEC for a managed zone, or creating a managed zone with DNSSEC, the DNSSEC signing algorithms and the denial-of-existence type can be selected. Changing the DNSSEC settings is only effective for a managed zone if DNSSEC is not already enabled. If the need exists to change the settings for a managed zone where it has been enabled, turn DNSSEC off and then re-enable it with different settings."

  tag cis_scored: false
  tag cis_level: 1
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['CM-6']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/dns/dnssec-advanced#advanced_signing_options'

  managed_zone_names = google_dns_managed_zones(project: gcp_project_id).zone_names

  if managed_zone_names.empty?
    describe "[#{gcp_project_id}] does not have DNS Zones. This test is Not Applicable." do
      skip "[#{gcp_project_id}] does not have DNS Zones."
    end
  else
    managed_zone_names.each do |dnszone|
      zone = google_dns_managed_zone(project: gcp_project_id, zone: dnszone)
      if zone.visibility == 'private'
        describe "[#{gcp_project_id}] DNS zone #{dnszone} has private visibility. This test is not applicable for private zones." do
          skip "[#{gcp_project_id}] DNS zone #{dnszone} has private visibility."
        end
      elsif zone.dnssec_config.state == 'on'
        zone.dnssec_config.default_key_specs.select { |spec| spec.key_type == 'zoneSigning' }.each do |spec|
          impact 'medium'
          describe "[#{gcp_project_id}] DNS Zone [#{dnszone}] with DNSSEC zone-signing" do
            subject { spec }
            its('algorithm') { should_not cmp 'RSASHA1' }
            its('algorithm') { should_not cmp nil }
          end
        end
      else
        impact 'medium'
        describe "[#{gcp_project_id}] DNS Zone [#{dnszone}] DNSSEC" do
          subject { 'off' }
          it { should cmp 'on' }
        end
      end
    end
  end
end
