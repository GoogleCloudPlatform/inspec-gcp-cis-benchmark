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

title 'Ensure Logging is enabled for HTTP(S) Load Balancer'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '2.16'
control_abbrev = 'logging'

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'medium'

  title "[#{control_abbrev.upcase}] Ensure Logging is enabled for HTTP(S) Load Balancer"

  desc 'Logging enabled on a HTTPS Load Balancer will show all network traffic and its destination.'
  desc 'rationale', 'Logging will allow you to view HTTPS network traffic to your web applications. On high use systems with a high percentage sample rate, the logging file may grow to high capacity in a short amount of time. Ensure that the sample rate is set appropriately so that storage costs are not exorbitant.'

  tag cis_scored: false
  tag cis_level: 2
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: %w[] # Add relevant NIST controls if any in future

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/load-balancing/'
  ref 'GCP Docs', url: 'https://cloud.google.com/load-balancing/docs/https/https-logging-monitoring#gcloud:-global-mode'
  ref 'GCP Docs', url: 'https://cloud.google.com/sdk/gcloud/reference/compute/backend-services/'
  describe 'This control is not scored' do
    skip 'This control is not scored'
  end
end
