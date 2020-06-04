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

title 'Ensure that Cloud Audit Logging is configured properly across all services and all users from a project '

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '2.1'
control_abbrev = 'logging'

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'low'

  title "[#{control_abbrev.upcase}] Ensure that Cloud Audit Logging is configured properly across all services and a
l users from a project "

  desc "It is recommended that Cloud Audit Logging is configured to track all Admin activities and
read, write access to user data."
  desc 'rationale', "Cloud Audit Logging maintains two audit logs for each project and organization: Admin Activity
nd Data Access.

1. Admin Activity logs contain log entries for API calls or other administrative actions that modify the configurati
n or metadata of resources. Admin Activity audit logs are enabled for all services and cannot be configured.
2. Data Access audit logs record API calls that create, modify, or read user-provided data. These are disabled by de
ault and should be enabled.  There are three kinds of Data Access audit log information:
   - Admin read: Records operations that read metadata or configuration information. Admin Activity audit logs recor
 writes of metadata and configuration information which cannot be disabled.
   - Data read: Records operations that read user-provided data.
   - Data write: Records operations that write user-provided data.

It is recommended to have effective default audit config configured in such a way that:
1. logtype is set to DATA_READ (to logs user activity tracking) and DATA_WRITES (to log changes/tampering to user data)
2. audit config is enabled for all the services supported by Data Access audit logs feature
3. Logs should be captured for all users. i.e. there are no exempted users in any of the audit config section. This will ensure overriding audit config will not contradict the requirement."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/logging/docs/audit/'
  ref 'GCP Docs', url: 'https://cloud.google.com/logging/docs/audit/configure-data-access'

  describe google_project_logging_audit_config(project: gcp_project_id) do
    its('default_types') { should include 'DATA_READ' }
    its('default_types') { should include 'DATA_WRITE' }
    it { should_not have_default_exempted_members }
  end
end
