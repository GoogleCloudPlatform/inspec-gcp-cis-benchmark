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

title 'Ensure that Cloud SQL database instances are configured with automated backups'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "6.07"
control_abbrev = "db"

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure that Cloud SQL database instances are configured with automated backups"

  desc "It is recommended to have all SQL database instances set to enable automated backups."
  desc "rationale", "Backups provide a way to restore a Cloud SQL instance to recover lost data or recover from a problem
                     with that instance. Automated backups need to be set for any instance that contains data that should 
                     be protected from loss or damage"

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/sql/docs/postgres/configure-ssl-instance"

  google_sql_database_instances(project: gcp_project_id).instance_names.each do |db|
    describe "[#{gcp_project_id}] CloudSQL #{db} should have automated backups enabled and have a start time" do
      subject { google_sql_database_instance(project: gcp_project_id, database: db).settings.backup_configuration.item }
          it { should include(:enabled => true) }
          it { should_not include(:start_time => '') }
    end
  end
end 
