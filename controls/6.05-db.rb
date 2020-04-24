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

title 'Database Server should accept connections only from trusted Network(s)/IP(s) and restrict access from the world'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "6.5"
control_abbrev = "db"

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Database Server should accept connections only from trusted Network(s)/IP(s) and restrict access from the world"

  desc "Database Server should accept connections only from trusted Network(s)/IP(s) and restrict access from the world."
  desc "rationale", "To minimize attack surface on a Database server instance, only trusted/known and required IP(s) should be white-listed to connect to it."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/sql/docs/mysql/configure-ip"

  google_sql_database_instances(project: gcp_project_id).instance_names.each do |db|
      describe "[#{gcp_project_id}] CloudSQL #{db}" do
        subject { google_sql_database_instance(project: gcp_project_id, database: db).authorized_networks }
        it { should_not include('0.0.0.0/0') }
     end
  end
end
