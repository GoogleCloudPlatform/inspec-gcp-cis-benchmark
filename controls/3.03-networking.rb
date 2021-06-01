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

title 'Ensure that DNSSEC is enabled for Cloud DNS'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '3.3'
control_abbrev = 'networking'

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'medium'

  title "[#{control_abbrev.upcase}] Ensure that DNSSEC is enabled for Cloud DNS"

  desc 'Cloud DNS is a fast, reliable and cost-effective Domain Name System that powers millions of domains on the internet. DNSSEC in Cloud DNS enables domain owners to take easy steps to protect their domains against DNS hijacking and man-in-the-middle and other attacks.'
  desc 'rationale', 'Domain Name System Security Extensions (DNSSEC) adds security to the Domain Name System (DNS) protocol by enabling DNS responses to be validated. Having a trustworthy Domain Name System (DNS) that translates a domain name like www.example.com into its associated IP address is an increasingly important building block of today’s web-based applications. Attackers can hijack this process of domain/IP lookup and redirect users to a malicious site through DNS hijacking and man-in-the-middle attacks. DNSSEC helps mitigate the risk of such attacks by cryptographically signing DNS records. As a result, it prevents attackers from issuing fake DNS responses that may misdirect browsers to nefarious websites.'

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: []

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloudplatform.googleblog.com/2017/11/DNSSEC-now-available-in-Cloud-DNS.html'
  ref 'GCP Docs', url: 'https://cloud.google.com/dns/dnssec-config#enabling'
  ref 'GCP Docs', url: 'https://cloud.google.com/dns/dnssec'

  managed_zone_names = google_dns_managed_zones(project: gcp_project_id).where(visibility: 'public').zone_names
  if managed_zone_names.empty?
    impact 'none'
    describe "[#{gcp_project_id}] does not have DNS Zones with Public visibility. This test is Not Applicable." do
      skip "[#{gcp_project_id}] does not have DNS Zones with Public visibility."
    end
  else
    managed_zone_names.each do |dnszone|
      describe "[#{gcp_project_id}] DNS Zone [#{dnszone}] with DNSSEC" do
        subject { google_dns_managed_zone(project: gcp_project_id, zone: dnszone) }
        its('dnssec_config.state') { should cmp 'on' }
      end
    end
  end
end
