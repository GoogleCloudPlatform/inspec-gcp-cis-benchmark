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

title 'Ensure all data in BigQuery has been classified'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '7.4'
control_abbrev = 'storage'

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'medium'
  title "[#{control_abbrev.upcase}] Ensure all data in BigQuery has been classified"
  desc 'BigQuery tables can contain sensitive data that for security purposes should be discovered, monitored,
  classified, and protected. Google Clouds Sensitive Data Protection tools can automatically provide data classification
  of all BigQuery data across an organization.'
  desc 'rationale', 'Using a cloud service or 3rd party software to continuously monitor and automate the process of data
  discovery and classification for BigQuery tables is an important part of protecting the data.
  Sensitive Data Protection is a fully managed data protection and data privacy platform that uses machine learning and pattern
  matching to discover and classify sensitive data in Google Cloud.'

  tag cis_scored: false
  tag cis_level: 2
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['AC-2']

  ref 'CIS Benchmark', url: cis_url.to_s

  ref 'GCP Docs', url: 'https://cloud.google.com/dlp/docs/data-profiles'
  ref 'GCP Docs', url: 'https://cloud.google.com/dlp/docs/analyze-data-profiles'
  ref 'GCP Docs', url: 'https://cloud.google.com/dlp/docs/data-profiles-remediation'
  ref 'GCP Docs', url: 'https://cloud.google.com/dlp/docs/send-profiles-to-scc'
  ref 'GCP Docs', url: 'https://cloud.google.com/dlp/docs/profile-org-folder#chronicle'
  ref 'GCP Docs', url: 'https://cloud.google.com/dlp/docs/profile-org-folder#publish-pubsub'

  describe 'This control is not scored' do
    skip 'This control is not scored'
  end
end
