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

# title 'Ensure that MySql database instance does not allow anyone to connect with administrative privileges.'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '6.1'
control_abbrev = 'db'

sql_cache = CloudSQLCache(project: gcp_project_id)
sql_instance_names = sql_cache.instance_names

# 6.1.1
sub_control_id = "#{control_id}.1"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 'high'

  title "[#{control_abbrev.upcase}] Ensure that MySql database instance does not allow anyone to connect with administrative privileges."

  desc "It is recommended to set a password for the administrative user (root by default) to prevent unauthorized access to the SQL database Instances.
        This recommendation is applicable only for MySql Instances. PostgreSQL does not offer any setting for No Password from cloud console."
  desc 'rationale', 'At the time of MySql Instance creation, not providing a administrative password allows anyone to connect to the SQL database instance with administrative privileges. Root password should be set to ensure only authorized users have these privileges.'

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: sub_control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['IA-5']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/mysql/create-manage-users'
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/mysql/create-instance'

  describe 'This control is not scored' do
    skip 'This control is not scored'
  end
end

# 6.1.2
sub_control_id = "#{control_id}.2"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 'none'

  title "[#{control_abbrev.upcase}] Ensure 'skip_show_database' database flag for Cloud SQL Mysql
  instance is set to 'on'"

  desc 'It is recommended to set skip_show_database database flag for Cloud SQL Mysql instance to on'
  desc 'rationale', "'skip_show_database' database flag prevents people from using the SHOW DATABASES
statement if they do not have the SHOW DATABASES privilege. This can improve security if
you have concerns about users being able to see databases belonging to other users. Its
effect depends on the SHOW DATABASES privilege: If the variable value is ON, the SHOW
DATABASES statement is permitted only to users who have the SHOW DATABASES
privilege, and the statement displays all database names. If the value is OFF, SHOW
DATABASES is permitted to all users, but displays the names of only those databases for
which the user has the SHOW DATABASES or other privilege. This recommendation is
applicable to Mysql database instances."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: sub_control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['AC-3']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/mysql/flags'

  sql_instance_names.each do |db|
    if sql_cache.instance_objects[db].database_version.include? 'MYSQL'
      impact 'medium'
      if sql_cache.instance_objects[db].settings.database_flags.nil?
        describe "[#{gcp_project_id} , #{db} ] does not any have database flags." do
          subject { false }
          it { should be true }
        end
      else
        describe.one do
          sql_cache.instance_objects[db].settings.database_flags.each do |flag|
            next unless flag.name == 'skip_show_database'
            describe flag do
              its('name') { should cmp 'skip_show_database' }
              its('value') { should cmp 'on' }
            end
          end
        end
      end
    else
      describe "[#{gcp_project_id}] [#{db}] is not a MySQL database. This test is Not Applicable." do
        skip "[#{gcp_project_id}] [#{db}] is not a MySQL database"
      end
    end
  end

  if sql_instance_names.empty?
    describe 'There are no Cloud SQL Instances in this project. This test is Not Applicable.' do
      skip 'There are no Cloud SQL Instances in this project'
    end
  end
end

# 6.1.3
sub_control_id = "#{control_id}.3"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 'none'

  title "[#{control_abbrev.upcase}] Ensure that the 'local_infile' database flag for a Cloud SQL Mysql instance is set to 'off'"

  desc 'It is recommended to set the local_infile database flag for a Cloud SQL MySQL instance to off.'
  desc 'rationale', "The local_infile flag controls the server-side LOCAL capability for LOAD DATA statements. Depending on the
                    local_infile setting, the server refuses or permits local data loading by clients that have LOCAL enabled on
                    the client side."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: sub_control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['SC-1']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/mysql/flags'

  sql_instance_names.each do |db|
    if sql_cache.instance_objects[db].database_version.include? 'MYSQL'
      if sql_cache.instance_objects[db].settings.database_flags.nil?
        impact 'medium'
        describe "[#{gcp_project_id} , #{db} ] does not any have database flags." do
          subject { false }
          it { should be true }
        end
      else
        describe.one do
          sql_cache.instance_objects[db].settings.database_flags.each do |flag|
            next unless flag.name == 'local_infile'
            impact 'medium'
            describe flag do
              its('name') { should cmp 'local_infile' }
              its('value') { should cmp 'off' }
            end
          end
        end
      end
    else
      describe "[#{gcp_project_id}] [#{db}] is not a MySQL database. This test is Not Applicable." do
        skip "[#{gcp_project_id}] [#{db}] is not a MySQL database"
      end
    end
  end

  if sql_instance_names.empty?
    describe "[#{gcp_project_id}] does not have CloudSQL instances. This test is Not Applicable." do
      skip "[#{gcp_project_id}] does not have CloudSQL instances."
    end
  end
end
