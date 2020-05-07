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

title 'Ensure that Cloud SQL database instances do not have public IPs'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "6.6"
control_abbrev = "db"

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure that Cloud SQL database instances do not have public IPs"

  desc "It is recommended to configure Second Generation Sql instance to use private IPs instead of public IPs."
  desc "rationale", "To lower the organization's attack surface, Cloud SQL databases should not have public IPs. Private IPs provide improved network security and lower latency for your application."

  tag cis_scored: true
  tag cis_level: 2
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/sql/docs/mysql/configure-private-ip"

  unless google_sql_database_instances(project: gcp_project_id).instance_names.empty?
    google_sql_database_instances(project: gcp_project_id).instance_names.each do |db|
      google_sql_database_instance(project: gcp_project_id, database: db).ip_addresses.each do |ip_address|
        describe "[#{gcp_project_id}] CloudSQL #{db}" do
          subject { ip_address }
            its('type') { should_not include('PRIMARY') }  
        end
      end
    end
  else
    impact 0
    describe "[#{gcp_project_id}] does not have CloudSQL instances. This test is Not Applicable." do
      skip "[#{gcp_project_id}] does not have CloudSQL instances."
    end
  end
end

