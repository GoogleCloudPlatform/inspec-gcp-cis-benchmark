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

title 'Ensure that Cloud SQL database instances are configured with automated backups'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = '6.7'
control_abbrev = 'db'

sql_cache = CloudSQLCache(project: gcp_project_id)

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure that Cloud SQL database instances are configured with automated backups"

  desc 'It is recommended to have all SQL database instances set to enable automated backups.'
  desc 'rationale', 'Backups provide a way to restore a Cloud SQL instance to recover lost data or recover from a problem
                     with that instance. Automated backups need to be set for any instance that contains data that should
                     be protected from loss or damage'

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/mysql/backup-recovery/backups'
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/postgres/backup-recovery/backing-up'

  if sql_cache.instance_names.empty?
    impact 0
    describe "[#{gcp_project_id}] does not have any CloudSQL instances, this test is Not Applicable" do
      skip "[#{gcp_project_id}] does not have any CloudSQL instances"
    end
  else
    sql_cache.instance_names.each do |db|
      describe "[#{gcp_project_id}] CloudSQL #{db} should have automated backups enabled and have a start time" do
        subject { sql_cache.instance_objects[db].settings.backup_configuration }
        its('enabled') { should cmp true }
        its('start_time') { should_not eq '' }
      end
    end
  end
end
