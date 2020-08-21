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

title 'Ensure that Cloud SQL database Instances are secure'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '6.2'
control_abbrev = 'db'

sql_cache = CloudSQLCache(project: gcp_project_id)

# 6.2.1
sub_control_id = "#{control_id}.1"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 'medium'

  title "[#{control_abbrev.upcase}] Ensure that the 'log_checkpoints' database flag for Cloud SQL PostgreSQL instance is set to 'on'"

  desc 'Enabling log_checkpoints causes checkpoints and restart points to be logged in the server log. Some statistics are included in the log messages, including the number of buffers written and the time spent writing them. '
  desc 'rationale', 'Enable system logging to include detailed information such as an event source, date,user, timestamp, source addresses, destination addresses, and other useful elements.'

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: sub_control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/postgres/flags#setting_a_database_flag'

  sql_cache.instance_names.each do |db|
    if sql_cache.instance_objects[db].database_version.include? 'POSTGRES'
      if sql_cache.instance_objects[db].settings.database_flags.nil?
        impact 'medium'
        describe "[#{gcp_project_id} , #{db} ] does not any have database flags." do
          subject { false }
          it { should be true }
        end
      else
        impact 'medium'
        describe.one do
          sql_cache.instance_objects[db].settings.database_flags.each do |flag|
            describe "[#{gcp_project_id} , #{db} ] should have a database flag 'log_checkpoints' set to 'on' " do
              subject { flag }
              its('name') { should cmp 'log_checkpoints' }
              its('value') { should cmp 'on' }
            end
          end
        end
      end
    else
      impact 'none'
      describe "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database. This test is Not Applicable." do
        skip "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database"
      end
    end
  end
end

# 6.2.2
sub_control_id = "#{control_id}.2"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 'medium'

  title "[#{control_abbrev.upcase}] Ensure that the 'log_connections' database flag for Cloud SQL PostgreSQL instance is set to 'on'"

  desc 'Enabling the log_connections setting causes each attempted connection to the server to be logged, along with successful completion of client authentication. '
  desc 'rationale', "PostgreSQL does not log attempted connections by default. Enabling the log_connections setting will create log entries for each attempted connection
                    as well as successful completion of client authentication which can be useful in troubleshooting issues and to determine any unusual connection attempts to the server."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: sub_control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/postgres/flags#setting_a_database_flag'
  ref 'GCP Docs', url: 'https://www.postgresql.org/docs/9.6/runtime-config-logging.html#RUNTIME-CONFIG-LOGGING-WHAT'

  sql_cache.instance_names.each do |db|
    if sql_cache.instance_objects[db].database_version.include? 'POSTGRES'
      if sql_cache.instance_objects[db].settings.database_flags.nil?
        impact 'medium'
        describe "[#{gcp_project_id} , #{db} ] does not any have database flags." do
          subject { false }
          it { should be true }
        end
      else
        impact 'medium'
        describe.one do
          sql_cache.instance_objects[db].settings.database_flags.each do |flag|
            describe "[#{gcp_project_id} , #{db} ] should have a database flag 'log_connections' set to 'on' " do
              subject { flag }
              its('name') { should cmp 'log_connections' }
              its('value') { should cmp 'on' }
            end
          end
        end
      end
    else
      impact 'none'
      describe "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database. This test is Not Applicable." do
        skip "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database"
      end
    end
  end
end

# 6.2.3
sub_control_id = "#{control_id}.3"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 'medium'

  title "[#{control_abbrev.upcase}] Ensure that the 'log_disconnections' database flag for Cloud SQL PostgreSQL instance is set to 'on'"

  desc 'Enabling the log_disconnections setting logs the end of each session, including the session duration.'
  desc 'rationale', "PostgreSQL does not log session details such as duration and session end by default. Enabling the log_disconnections
                    setting will create log entries at the end of each session which can be useful in troubleshooting issues and determine any unusual activity across a time period"

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: sub_control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/postgres/flags#setting_a_database_flag'
  ref 'GCP Docs', url: 'https://www.postgresql.org/docs/9.6/runtime-config-logging.html#RUNTIME-CONFIG-LOGGING-WHAT'

  sql_cache.instance_names.each do |db|
    if sql_cache.instance_objects[db].database_version.include? 'POSTGRES'
      if sql_cache.instance_objects[db].settings.database_flags.nil?
        impact 'medium'
        describe "[#{gcp_project_id} , #{db} ] does not any have database flags." do
          subject { false }
          it { should be true }
        end
      else
        impact 'medium'
        describe.one do
          sql_cache.instance_objects[db].settings.database_flags.each do |flag|
            describe "[#{gcp_project_id} , #{db} ] should have a database flag 'log_disconnections' set to 'on' " do
              subject { flag }
              its('name') { should cmp 'log_disconnections' }
              its('value') { should cmp 'on' }
            end
          end
        end
      end
    else
      impact 'none'
      describe "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database. This test is Not Applicable." do
        skip "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database"
      end
    end
  end
end

# 6.2.4
sub_control_id = "#{control_id}.4"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 'medium'

  title "[#{control_abbrev.upcase}] Ensure that the 'log_lock_waits' database flag for Cloud SQL PostgreSQL instance is set to 'on'"

  desc 'Enabling the log_lock_waits flag for a PostgreSQL instance creates a log for any session waits that take longer than the alloted deadlock_timeout time to acquire a lock.'
  desc 'rationale', "The deadlock timeout defines the time to wait on a lock before checking for any conditions. Frequent run overs on deadlock timeout can be an indication of an
                    underlying issue. Logging such waits on locks by enabling the log_lock_waits flag can be used to identify poor performance due to locking delays or if a
                    specially-crafted SQL is attempting to starve resources through holding locks for excessive amounts of time."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: sub_control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/postgres/flags#setting_a_database_flag'
  ref 'GCP Docs', url: 'https://www.postgresql.org/docs/9.6/runtime-config-logging.html#RUNTIME-CONFIG-LOGGING-WHAT'

  sql_cache.instance_names.each do |db|
    if sql_cache.instance_objects[db].database_version.include? 'POSTGRES'
      if sql_cache.instance_objects[db].settings.database_flags.nil?
        impact 'medium'
        describe "[#{gcp_project_id} , #{db} ] does not any have database flags." do
          subject { false }
          it { should be true }
        end
      else
        impact 'medium'
        describe.one do
          sql_cache.instance_objects[db].settings.database_flags.each do |flag|
            describe "[#{gcp_project_id} , #{db} ] should have a database flag 'log_lock_waits' set to 'on' " do
              subject { flag }
              its('name') { should cmp 'log_lock_waits' }
              its('value') { should cmp 'on' }
            end
          end
        end
      end
    else
      impact 'none'
      describe "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database. This test is Not Applicable." do
        skip "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database"
      end
    end
  end
end

# 6.2.5
sub_control_id = "#{control_id}.5"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 'medium'

  title "[#{control_abbrev.upcase}] Ensure that the 'log_min_messages' database flag for Cloud SQL PostgreSQL instance is set appropriately"

  desc 'The log_min_error_statement flag defines the minimum message severity level that is considered as an error statement. Messages for error statements are logged with the SQL statement '
  desc 'rationale', 'ERROR is considered the best practice setting. Auditing helps in troubleshooting operational problems and also permits forensic analysis. If log_min_error_statement is not set to the correct value, messages may not be classified as error messages appropriately'

  tag cis_scored: false
  tag cis_level: 1
  tag cis_gcp: sub_control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/postgres/flags#setting_a_database_flag'
  ref 'GCP Docs', url: 'https://www.postgresql.org/docs/9.6/runtime-config-logging.html#RUNTIME-CONFIG-LOGGING-WHAT'

  sql_cache.instance_names.each do |db|
    if sql_cache.instance_objects[db].database_version.include? 'POSTGRES'
      if sql_cache.instance_objects[db].settings.database_flags.nil?
        impact 'medium'
        describe "[#{gcp_project_id} , #{db} ] does not any have database flags." do
          subject { false }
          it { should be true }
        end
      else
        impact 'medium'
        describe.one do
          sql_cache.instance_objects[db].settings.database_flags.each do |flag|
            describe "[#{gcp_project_id} , #{db} ] should have a database flag 'log_min_error_statement' set to 'ERROR' " do
              subject { flag }
              its('name') { should cmp 'log_min_error_statement' }
              its('value') { should cmp 'ERROR' }
            end
          end
        end
      end
    else
      impact 'none'
      describe "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database. This test is Not Applicable." do
        skip "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database"
      end
    end
  end
end

# 6.2.6
sub_control_id = "#{control_id}.6"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 'medium'

  title "[#{control_abbrev.upcase}] Ensure that the 'log_temp_files' database flag for Cloud SQL PostgreSQL instance is set to '0' (on)"

  desc 'PostgreSQL can create a temporary file for actions such as sorting, hashing and temporary query results when these operations exceed work_mem. The log_temp_files flag controls logging names and the file size when it is deleted.'
  desc 'rationale', 'If all temporary files are not logged, it may be more difficult to identify potential performance issues that may be due to either poor application coding or deliberate resource starvation attempts.'
  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: sub_control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/postgres/flags#setting_a_database_flag'
  ref 'GCP Docs', url: 'https://www.postgresql.org/docs/9.6/runtime-config-logging.html#RUNTIME-CONFIG-LOGGING-WHAT'

  sql_cache.instance_names.each do |db|
    if sql_cache.instance_objects[db].database_version.include? 'POSTGRES'
      if sql_cache.instance_objects[db].settings.database_flags.nil?
        impact 'medium'
        describe "[#{gcp_project_id} , #{db} ] does not any have database flags." do
          subject { false }
          it { should be true }
        end
      else
        impact 'medium'
        describe.one do
          sql_cache.instance_objects[db].settings.database_flags.each do |flag|
            describe "[#{gcp_project_id} , #{db} ] should have a database flag 'log_temp_files' set to '0' " do
              subject { flag }
              its('name') { should cmp 'log_temp_files' }
              its('value') { should cmp '0' }
            end
          end
        end
      end
    else
      impact 'none'
      describe "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database. This test is Not Applicable." do
        skip "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database"
      end
    end
  end
end

# 6.2.7
sub_control_id = "#{control_id}.7"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 'medium'

  title "[#{control_abbrev.upcase}] Ensure that the 'log_min_duration_statement' database flag for Cloud SQL PostgreSQL instance is set to '-1' (disabled)"

  desc 'The log_min_duration_statement flag defines the minimum amount of execution time of a statement in milliseconds where the total duration of the statement is logged.'
  desc 'rationale', 'Logging SQL statements may include sensitive information that should not be recorded in logs. This recommendation is applicable to PostgreSQL database instances.'

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: sub_control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/postgres/flags#setting_a_database_flag'
  ref 'GCP Docs', url: 'https://www.postgresql.org/docs/9.6/runtime-config-logging.html#RUNTIME-CONFIG-LOGGING-WHAT'

  sql_cache.instance_names.each do |db|
    if sql_cache.instance_objects[db].database_version.include? 'POSTGRES'
      if sql_cache.instance_objects[db].settings.database_flags.nil?
        impact 'medium'
        describe "[#{gcp_project_id} , #{db} ] does not any have database flags." do
          subject { false }
          it { should be true }
        end
      else
        impact 'medium'
        describe.one do
          sql_cache.instance_objects[db].settings.database_flags.each do |flag|
            describe "[#{gcp_project_id} , #{db} ] should have a database flag 'log_min_duration_statement' set to '-1' " do
              subject { flag }
              its('name') { should cmp 'log_min_duration_statement' }
              its('value') { should cmp '-1' }
            end
          end
        end
      end
    else
      impact 'none'
      describe "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database. This test is Not Applicable." do
        skip "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database"
      end
    end
  end
end
