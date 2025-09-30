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

title 'Ensure That App Engine Applications Enforce HTTPS Connections (Manual)'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '4.10'
control_abbrev = 'vms' # Though App Engine, keeping consistent with section

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'low'

  title "[#{control_abbrev.upcase}] Ensure That App Engine Applications Enforce HTTPS Connections (Manual)"

  desc 'In order to maintain the highest level of security all connections to an application should be secure by default.'
  desc 'rationale', 'Insecure HTTP connections maybe subject to eavesdropping which can expose sensitive data. All connections to appengine will automatically be redirected to the HTTPS endpoint ensuring that all connections are secured by TLS.'

  tag cis_scored: false
  tag cis_level: 2
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: %w[] # Add relevant NIST controls if any in future

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP App Engine Docs', url: 'https://cloud.google.com/appengine/docs/standard/python3/config/appref'
  ref 'GCP App Engine Docs (Flexible)', url: 'https://cloud.google.com/appengine/docs/flexible/nodejs/configuring-your-app-with-app-yaml'

  describe 'This control is not scored' do
    skip 'This control is not scored'
  end
end
