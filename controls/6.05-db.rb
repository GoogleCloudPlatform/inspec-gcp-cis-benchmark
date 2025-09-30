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

title 'Ensure That Cloud SQL Database Instances Do Not Implicitly Whitelist All Public IP Addresses'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '6.5'
control_abbrev = 'db'

sql_cache = CloudSQLCache(project: gcp_project_id)
sql_instance_names = sql_cache.instance_names

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'medium'

  title "[#{control_abbrev.upcase}] Ensure That Cloud SQL Database Instances Do Not Implicitly Whitelist All Public IP Addresses"

  desc 'Database Server should accept connections only from trusted Network(s)/IP(s) and restrict access from public IP addresses.'
  desc 'rationale', 'To minimize attack surface on a Database server instance, only trusted/known and required IP(s) should be
        white-listed to connect to it. An authorized network should not have IPs/networks configured to \'0.0.0.0/0\' which will allow
        access to the instance from anywhere in the world. Note that authorized networks apply only to instances with public IPs.'

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: %w[SC-1 AC-3]

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/mysql/configure-ip'
  ref 'GCP Docs', url: 'https://console.cloud.google.com/iam-admin/orgpolicies/sql-restrictAuthorizedNetworks'
  ref 'GCP Docs', url: 'https://cloud.google.com/resource-manager/docs/organization-policy/org-policy-constraints'
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/mysql/connection-org-policy'

  if sql_instance_names.empty?
    impact 'none'
    describe "[#{gcp_project_id}] does not have CloudSQL instances. This test is Not Applicable." do
      skip "[#{gcp_project_id}] does not have CloudSQL instances."
    end
  else
    sql_instance_names.each do |db|
      describe "[#{gcp_project_id}] CloudSQL #{db}" do
        subject { sql_cache.instance_objects[db].settings.ip_configuration.authorized_networks }
        it { should_not include('0.0.0.0/0') }
      end
    end
  end
end
