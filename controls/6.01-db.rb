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

title 'Ensure that MySql database instances are secure.'

#title 'Ensure that MySql database instance does not allow anyone to connect with administrative privileges.'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "6.1"
control_abbrev = "db"

# 6.1.1
sub_control_id = "#{control_id}.1"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure that MySql database instance does not allow anyone to connect with administrative privileges."

  desc "It is recommended to set a password for the administrative user (root by default) to prevent unauthorized access to the SQL database Instances.
        This recommendation is applicable only for MySql Instances. PostgreSQL does not offer any setting for No Password from cloud console."
  desc "rationale", "At the time of MySql Instance creation, not providing a administrative password allows anyone to connect to the SQL database instance with administrative privileges. Root password should be set to ensure only authorized users have these privileges."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{sub_control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/sql/docs/mysql/create-manage-users"
  ref "GCP Docs", url: "https://cloud.google.com/sql/docs/mysql/create-instance"

  describe "Not scored" do
    before do
      skip
    end
    it {should eq "Not scored"}
  end

end

# 6.1.2
sub_control_id = "#{control_id}.2"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 1.1

  title "[#{control_abbrev.upcase}] Ensure that the 'local_infile' database flag for a Cloud SQL Mysql instance is set to 'off'"

  desc "It is recommended to set the local_infile database flag for a Cloud SQL MySQL instance to off."
  desc "rationale", "The local_infile flag controls the server-side LOCAL capability for LOAD DATA statements. Depending on the 
                    local_infile setting, the server refuses or permits local data loading by clients that have LOCAL enabled on 
                    the client side."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{sub_control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/sql/docs/mysql/flags"

  google_sql_database_instances(project: gcp_project_id).instance_names.each do |db|
      if google_sql_database_instance(project: gcp_project_id, database: db).database_version.include? 'MYSQL'
        if defined? google_sql_database_instance(project: gcp_project_id, database: db).settings.database_flags 
          google_sql_database_instance(project: gcp_project_id, database: db).settings.database_flags.each do |flag|
            describe flag.item do
              it { should include(:name => 'local_infile') }
              it { should include(:value => 'off') }
            end
          end
        else
          describe "[#{gcp_project_id} , #{db} ] does not any have database flags." do
            subject { false }
            it { should be true }
          end
        end
      else 
        impact 0 
        describe "[#{gcp_project_id}] [#{db}] is not a MySQL database. This test is Not Applicable." do
            skip "[#{gcp_project_id}] is not a MySQL database"
        end
    end 
  end 
end 