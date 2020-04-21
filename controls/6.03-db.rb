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

title 'Ensure that Cloud SQL Server database Instances are secure'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "6.3"
control_abbrev = "db"

# 6.3.1
sub_control_id = "#{control_id}.1"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 1.1

  title "[#{control_abbrev.upcase}] Ensure that the 'cross db ownership chaining' database flag for Cloud SQL Server instance is set to 'off'"

  desc "It is recommended to set cross db ownership chaining database flag for Cloud SQL SQL Server instance to off. "
  desc "rationale", "Use the cross db ownership for chaining option to configure cross-database ownership chaining for an instance of 
                     Microsoft SQL Server. This server option allows you to control cross-database ownership chaining at the database level or 
                     to allow cross-database ownership chaining for all databases.Enabling cross db ownership is not recommended unless all of the 
                     databases hosted by the instance of SQL Server must participate in cross-database ownership chaining and you are aware of the 
                     security implications of this setting"

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{sub_control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/sql/docs/sqlserver/flags"
  ref "GCP Docs", url: "https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/cross-db-ownership-chaining-server-configuration-option?view=sql-server-ver15"

  google_sql_database_instances(project: gcp_project_id).instance_names.each do |db|
    describe.one do
      google_sql_database_instance(project: gcp_project_id, database: db).settings.database_flags.each do |flag|
        describe flag.item do
          it { should include(:name => 'cross db ownership chaining') }
          it { should include(:value => 'off') }
        end
      end
	  end
  end 
end 

# 6.3.2
sub_control_id = "#{control_id}.2"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 1.1

  title "[#{control_abbrev.upcase}] Ensure that the 'contained database authentication' database flag for Cloud SQL server instance is set to 'off'"

  desc "It is recommended to set contained database authentication database flag for Cloud SQL on the SQL Server instance is set to off."
  desc "rationale", "A contained database includes all database settings and metadata required to define the database and has no configuration 
                    dependencies on the instance of the Database Engine where the database is installed. Users can connect to the database without authenticating 
                    a login at the Database Engine level. Isolating the database from the Database Engine makes it possible to easily move the database to another 
                    instance of SQL Server."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{sub_control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/sql/docs/sqlserver/flags"
  ref "GCP Docs", url: "https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/contained-database-authentication-server-configuration-option?view=sql-server-ver15"
  ref "GCP Docs", url: "https://docs.microsoft.com/en-us/sql/relational-databases/databases/security-best-practices-with-contained-databases?view=sql-server-ver15"

  google_sql_database_instances(project: gcp_project_id).instance_names.each do |db|
    describe.one do
      google_sql_database_instance(project: gcp_project_id, database: db).settings.database_flags.each do |flag|
        describe flag.item do
          it { should include(:name => 'contained database authentication') }
          it { should include(:value => 'off') }
        end
      end
	  end
  end 
end 