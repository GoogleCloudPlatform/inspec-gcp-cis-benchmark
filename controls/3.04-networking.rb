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

title 'Ensure that RSASHA1 is not used for key-signing key in Cloud DNS DNSSEC'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = '3.4'
control_abbrev = 'networking'

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'medium'

  title "[#{control_abbrev.upcase}] Ensure that RSASHA1 is not used for key-signing key in Cloud DNS DNSSEC"

  desc 'DNSSEC algorithm numbers in this registry may be used in CERT RRs. Zone signing (DNSSEC) and transaction security mechanisms (SIG(0) and TSIG) make use of particular subsets of these algorithms. The algorithm used for key signing should be recommended one and it should not be weak.'
  desc 'rationale', 'DNSSEC algorithm numbers in this registry may be used in CERT RRs. Zonesigning (DNSSEC) and transaction security mechanisms (SIG(0) and TSIG) make use of particular subsets of these algorithms.  The algorithm used for key signing should be recommended one and it should not be weak.

When enabling DNSSEC for a managed zone, or creating a managed zone with DNSSEC, you can select the DNSSEC signing algorithms and the denial-of-existence type. Changing the DNSSEC settings is only effective for a managed zone if DNSSEC is not already enabled. If you need to change the settings for a managed zone where it has been enabled, you can turn DNSSEC off and then re-enable it with different settings.'

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/dns/dnssec-advanced#advanced_signing_options'

  managed_zone_names = google_dns_managed_zones(project: gcp_project_id).zone_names

  unless managed_zone_names.empty?
    managed_zone_names.each do |dnszone|
      zone = google_dns_managed_zone(project: gcp_project_id, zone: dnszone)

      if zone.dnssec_config.state == 'on'
        zone.dnssec_config.default_key_specs.select { |spec| spec.key_type == 'keySigning' }.each do |spec|
          describe "[#{gcp_project_id}] DNS Zone [#{dnszone}] with DNSSEC key-signing" do
            subject { spec }
            its('algorithm') { should_not cmp 'RSASHA1' }
            its('algorithm') { should_not cmp nil }
          end
        end
      else
        describe "[#{gcp_project_id}] DNS Zone [#{dnszone}] DNSSEC" do
          subject { 'off' }
          it { should cmp 'on' }
        end
      end
    end
  else
    impact 'none'
    describe "[#{gcp_project_id}] does not have DNS Zones. This test is Not Applicable." do
      skip "[#{gcp_project_id}] does not have DNS Zones."
    end
  end
end
