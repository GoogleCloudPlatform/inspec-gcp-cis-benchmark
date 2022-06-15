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

title 'Ensure that Cloud SQL database instance requires all incoming connections to use SSL'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '6.4'
control_abbrev = 'db'

sql_cache = CloudSQLCache(project: gcp_project_id)
sql_instance_names = sql_cache.instance_names

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'high'

  title "[#{control_abbrev.upcase}] Ensure that Cloud SQL database instance requires all incoming connections to use SSL"

  desc 'It is recommended to enforce all incoming connections to SQL database instance to use SSL.'
  desc 'rationale', 'SQL database connections if successfully trapped (MITM); can reveal sensitive data like credentials, database queries, query outputs etc. For security, it is recommended to always use SSL encryption when connecting to your instance. This recommendation is applicable for Postgresql, MySql generation 1 and MySql generation 2 Instances.'

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: %w[SC-1 SC-8]

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/postgres/configure-ssl-instance'

  if sql_instance_names.empty?
    impact 'none'
    describe "[#{gcp_project_id}] does not have CloudSQL instances. This test is Not Applicable." do
      skip "[#{gcp_project_id}] does not have CloudSQL instances."
    end
  else
    sql_instance_names.each do |db|
      describe "[#{gcp_project_id}] CloudSQL #{db}" do
        subject { sql_cache.instance_objects[db] }
        it { should have_ip_configuration_require_ssl }
      end
    end
  end
end
