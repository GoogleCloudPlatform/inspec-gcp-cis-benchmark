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

title 'Ensure that RSASHA1 is not used for key-signing key in Cloud DNS DNSSEC'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "3.4"
control_abbrev = "networking"

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure that RSASHA1 is not used for key-signing key in Cloud DNS DNSSEC"

  desc "DNSSEC algorithm numbers in this registry may be used in CERT RRs. Zone signing (DNSSEC) and transaction security mechanisms (SIG(0) and TSIG) make use of particular subsets of these algorithms. The algorithm used for key signing should be recommended one and it should not be weak."
  desc "rationale", "DNSSEC algorithm numbers in this registry may be used in CERT RRs. Zonesigning (DNSSEC) and transaction security mechanisms (SIG(0) and TSIG) make use of particular subsets of these algorithms.  The algorithm used for key signing should be recommended one and it should not be weak.

When enabling DNSSEC for a managed zone, or creating a managed zone with DNSSEC, you can select the DNSSEC signing algorithms and the denial-of-existence type. Changing the DNSSEC settings is only effective for a managed zone if DNSSEC is not already enabled. If you need to change the settings for a managed zone where it has been enabled, you can turn DNSSEC off and then re-enable it with different settings."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/dns/dnssec-advanced#advanced_signing_options"

  google_dns_managed_zones(project: gcp_project_id).zone_names.each do |dnszone|
    describe "[#{gcp_project_id}] DNS Zone with DNSSEC" do
      subject { google_dns_managed_zone(project: gcp_project_id,  zone: dnszone) }
      its('key_signing_key_algorithm') { should_not be nil }
      its('key_signing_key_algorithm') { should_not cmp 'RSASHA1' }
    end
  end

end
