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

title 'Ensure No HTTPS or SSL Proxy Load Balancers Permit SSL Policies With Weak Cipher Suites'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '3.9'
control_abbrev = 'networking'

gcp_https_proxies = google_compute_target_https_proxies(project: gcp_project_id).names
gcp_ssl_policies = google_compute_ssl_policies(project: gcp_project_id).names

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'low'

  title "[#{control_abbrev.upcase}] Ensure No HTTPS or SSL Proxy Load Balancers Permit SSL Policies With Weak Cipher Suites"

  desc 'Secure Sockets Layer (SSL) policies determine what port Transport Layer Security (TLS) features clients are permitted to use when connecting to load balancers. To prevent usage of insecure features, SSL policies should use (a) at least TLS 1.2 with the MODERN profile; or (b) the RESTRICTED profile, because it effectively requires clients to use TLS 1.2 regardless of the chosen minimum TLS version; or (3) a CUSTOM profile that does not support any of the following features: TLS_RSA_WITH_AES_128_GCM_SHA256 TLS_RSA_WITH_AES_256_GCM_SHA384 TLS_RSA_WITH_AES_128_CBC_SHA TLS_RSA_WITH_AES_256_CBC_SHA TLS_RSA_WITH_3DES_EDE_CBC_SHA'
  desc 'rationale', 'Load balancers are used to efficiently distribute traffic across multiple servers. Both SSL proxy and HTTPS load balancers are external load balancers, meaning they distribute traffic from the Internet to a GCP network. GCP customers can configure load balancer SSL policies with a minimum TLS version (1.0, 1.1, or 1.2) that clients can use to establish a connection, along with a profile (Compatible, Modern, Restricted, or Custom) that specifies permissible cipher suites. To comply with users using outdated protocols, GCP load balancers can be configured to permit insecure cipher suites. In fact, the GCP default SSL policy uses a minimum TLS version of 1.0 and a Compatible profile, which allows the widest range of insecure cipher suites. As a result, it is easy for customers to configure a load balancer without even knowing that they are permitting outdated cipher suites.'

  tag cis_scored: false
  tag cis_level: 1
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['SC-1']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/load-balancing/docs/use-ssl-policies'
  ref 'GCP Docs', url: 'https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-52r.pdf'

  # All load balancers have custom/strong TLS profiles set

  gcp_https_proxies.each do |proxy|
    describe "[#{gcp_project_id}] HTTPS Proxy: #{proxy}" do
      subject { google_compute_target_https_proxy(project: gcp_project_id, name: proxy) }
      it 'should have a custom SSL policy configured' do
        expect(subject.ssl_policy).to_not cmp(nil)
      end
    end
  end
  # Ensure SSL Policies use strong TLS
  gcp_ssl_policies.each do |policy|
    case google_compute_ssl_policy(project: gcp_project_id, name: policy).profile
    when 'MODERN'
      describe "[#{gcp_project_id}] SSL Policy: #{policy}" do
        subject { google_compute_ssl_policy(project: gcp_project_id, name: policy) }
        it 'should minimally require TLS 1.2' do
          expect(subject.min_tls_version).to cmp('TLS_1_2')
        end
      end

    when 'RESTRICTED'
      describe "[#{gcp_project_id}] SSL Policy: #{policy} profile should be RESTRICTED" do
        subject { google_compute_ssl_policy(project: gcp_project_id, name: policy).profile }
        it { should cmp 'RESTRICTED' }
      end

    when 'CUSTOM'
      describe "[#{gcp_project_id}] SSL Policy: #{policy} profile CUSTOM should not contain these cipher suites [TLS_RSA_WITH_AES_128_GCM_SHA256, TLS_RSA_WITH_AES_256_GCM_SHA384, TLS_RSA_WITH_AES_128_CBC_SHA,  TLS_RSA_WITH_AES_256_CBC_SHA, TLS_RSA_WITH_3DES_EDE_CBC_SHA] " do
        subject { google_compute_ssl_policy(project: gcp_project_id, name: policy) }
        its('custom_features') { should_not be_in %w[TLS_RSA_WITH_AES_128_GCM_SHA256 TLS_RSA_WITH_AES_256_GCM_SHA384 TLS_RSA_WITH_AES_128_CBC_SHA TLS_RSA_WITH_AES_256_CBC_SHA TLS_RSA_WITH_3DES_EDE_CBC_SHA] }
      end
    end
  end

  if gcp_https_proxies.empty? && gcp_ssl_policies.empty?
    impact 'none'
    describe "[#{gcp_project_id}] No HTTPS or SSL proxy load balancers found. This test is Not Applicable." do
      skip "[#{gcp_project_id}] No HTTPS or SSL proxy load balancers found"
    end
  end
end
