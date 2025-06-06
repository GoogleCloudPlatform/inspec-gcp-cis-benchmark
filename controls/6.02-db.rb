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
log_min_messages = input('log_min_messages')
log_min_error_statement = input('log_min_error_statement')
log_error_verbosity = input('log_error_verbosity')
log_statement = input('log_statement')
control_id = '6.2'
control_abbrev = 'db'

sql_cache = CloudSQLCache(project: gcp_project_id)
sql_instance_names = sql_cache.instance_names

# 6.2.1
sub_control_id = "#{control_id}.1"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 'none'

  title "[#{control_abbrev.upcase}] Ensure ‘Log_error_verbosity’ Database Flag for Cloud SQL PostgreSQL Instance Is Set to ‘DEFAULT’ or Stricter"

  desc 'The log_error_verbosity flag controls the verbosity/details of messages logged. Valid values are:
        • TERSE
        • DEFAULT
        • VERBOSE
        TERSE excludes the logging of DETAIL, HINT, QUERY, and CONTEXT error information.
        VERBOSE output includes the SQLSTATE error code, source code file name, function name, and line number that generated the error.
        Ensure an appropriate value is set to \'DEFAULT\' or stricter.'

  desc 'rationale', 'Auditing helps in troubleshooting operational problems and also permits forensic analysis. If log_error_verbosity is not
        set to the correct value, too many details or too few details may be logged. This flag should be configured with a value of \'DEFAULT\'
        or stricter.
        This recommendation is applicable to PostgreSQL database instances.'

  tag cis_scored: true
  tag cis_level: 2
  tag cis_gcp: sub_control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['AU-3']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/postgres/flags'
  ref 'GCP Docs', url: 'https://www.postgresql.org/docs/current/runtime-config-logging.html#GUC-LOG-ERROR-VERBOSITY'

  sql_instance_names.each do |db|
    if sql_cache.instance_objects[db].database_version.include? 'POSTGRES'
      impact 'medium'
      if sql_cache.instance_objects[db].settings.database_flags.nil?
        describe "[#{gcp_project_id} , #{db} ] does not any have database flags." do
          subject { false }
          it { should be true }
        end
      else
        describe.one do
          sql_cache.instance_objects[db].settings.database_flags.each do |flag|
            next unless flag.name == 'log_error_verbosity'
            describe "[#{gcp_project_id} , #{db} ] should have a database flag 'log_error_verbosity' set to #{log_error_verbosity} " do
              subject { flag }
              its('name') { should cmp 'log_error_verbosity' }
              its('value') { should cmp log_error_verbosity }
            end
          end
        end
      end
    else
      describe "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database. This test is Not Applicable." do
        skip "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database"
      end
    end
  end

  if sql_instance_names.empty?
    describe "[#{gcp_project_id}] does not have CloudSQL instances. This test is Not Applicable." do
      skip "[#{gcp_project_id}] does not have CloudSQL instances."
    end
  end
end

# 6.2.2
sub_control_id = "#{control_id}.2"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 'none'

  title "[#{control_abbrev.upcase}] Ensure that the ‘Log_connections’ database flag for cloud SQL PostgreSQL instance is set to ‘on’"

  desc 'Enabling the log_connections setting causes each attempted connection to the server to be logged, along with successful completion
        of client authentication. This parameter cannot be changed after the session starts.'
  desc 'rationale', "PostgreSQL does not log attempted connections by default. Enabling the log_connections setting will create log entries
        for each attempted connection as well as successful completion of client authentication which can be useful in troubleshooting issues
        and to determine any unusual connection attempts to the server. This recommendation is applicable to PostgreSQL database instances."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: sub_control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['AU-3']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/postgres/flags'
  ref 'GCP Docs', url: 'https://www.postgresql.org/docs/current/runtime-config-logging.html#GUC-LOG-CONNECTIONS'

  sql_instance_names.each do |db|
    if sql_cache.instance_objects[db].database_version.include? 'POSTGRES'
      impact 'medium'
      if sql_cache.instance_objects[db].settings.database_flags.nil?
        describe "[#{gcp_project_id} , #{db} ] does not any have database flags." do
          subject { false }
          it { should be true }
        end
      else
        describe.one do
          sql_cache.instance_objects[db].settings.database_flags.each do |flag|
            next unless flag.name == 'log_connections'
            describe "[#{gcp_project_id} , #{db} ] should have a database flag 'log_connections' set to 'on' " do
              subject { flag }
              its('name') { should cmp 'log_connections' }
              its('value') { should cmp 'on' }
            end
          end
        end
      end
    else
      describe "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database. This test is Not Applicable." do
        skip "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database"
      end
    end
  end

  if sql_instance_names.empty?
    describe "[#{gcp_project_id}] does not have CloudSQL instances. This test is Not Applicable." do
      skip "[#{gcp_project_id}] does not have CloudSQL instances."
    end
  end
end

# 6.2.3
sub_control_id = "#{control_id}.3"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 'none'

  title "[#{control_abbrev.upcase}] Ensure that the ‘Log_disconnections’ database flag for cloud SQL PostgreSQL instance is set to ‘on’"

  desc 'Enabling the log_disconnections setting logs the end of each session, including the session duration.'
  desc 'rationale', "PostgreSQL does not log session details such as duration and session end by default. Enabling the log_disconnections
        setting will create log entries at the end of each session which can be useful in troubleshooting issues and determine any unusual
        activity across a time period. The log_disconnections and log_connections work hand in hand and generally, the pair would be enabled/disabled
        together. This recommendation is applicable to PostgreSQL database instances."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: sub_control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['AU-3']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/postgres/flags'
  ref 'GCP Docs', url: 'https://www.postgresql.org/docs/current/runtime-config-logging.html#GUC-LOG-DISCONNECTIONS'

  sql_instance_names.each do |db|
    if sql_cache.instance_objects[db].database_version.include? 'POSTGRES'
      impact 'medium'
      if sql_cache.instance_objects[db].settings.database_flags.nil?
        describe "[#{gcp_project_id} , #{db} ] does not any have database flags." do
          subject { false }
          it { should be true }
        end
      else
        describe.one do
          sql_cache.instance_objects[db].settings.database_flags.each do |flag|
            next unless flag.name == 'log_disconnections'
            describe "[#{gcp_project_id} , #{db} ] should have a database flag 'log_disconnections' set to 'on' " do
              subject { flag }
              its('name') { should cmp 'log_disconnections' }
              its('value') { should cmp 'on' }
            end
          end
        end
      end
    else
      describe "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database. This test is Not Applicable." do
        skip "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database"
      end
    end
  end

  if sql_instance_names.empty?
    describe "[#{gcp_project_id}] does not have CloudSQL instances. This test is Not Applicable." do
      skip "[#{gcp_project_id}] does not have CloudSQL instances."
    end
  end
end

# 6.2.4
sub_control_id = "#{control_id}.4"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 'none'

  title "[#{control_abbrev.upcase}] Ensure ‘Log_statement’ database flag for cloud SQL PostgreSQL instance is set appropriately"

  desc "The value of log_statement flag determined the SQL statements that are logged. Valid values are:
        • none
        • ddl
        • mod
        • all
      The value ddl logs all data definition statements. The value mod logs all ddl statements, plus data-modifying statements.
      The statements are logged after a basic parsing is done and statement type is determined, thus this does not logs statements
      with errors. When using extended query protocol, logging occurs after an Execute message is received and values of the Bind parameters are included.
      A value of 'ddl' is recommended unless otherwise directed by your organizations logging policy."
  desc 'rationale', "Auditing helps in forensic analysis. If log_statement is not set to the correct value, too many statements may be
      logged leading to issues in finding the relevant information from the logs, or too few statements may be logged with relevant information
      missing from the logs. Setting log_statement to align with your organizations security and logging policies facilitates later auditing and
      review of database activities. This recommendation is applicable to PostgreSQL database instances."

  tag cis_scored: true
  tag cis_level: 2
  tag cis_gcp: sub_control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['AU-3']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/postgres/flags'
  ref 'GCP Docs', url: 'https://www.postgresql.org/docs/current/runtime-config-logging.html#GUC-LOG-STATEMENT'

  sql_instance_names.each do |db|
    if sql_cache.instance_objects[db].database_version.include? 'POSTGRES'
      impact 'medium'
      if sql_cache.instance_objects[db].settings.database_flags.nil?
        describe "[#{gcp_project_id} , #{db} ] does not any have database flags." do
          subject { false }
          it { should be true }
        end
      else
        describe.one do
          sql_cache.instance_objects[db].settings.database_flags.each do |flag|
            next unless flag.name == 'log_duration'
            describe "[#{gcp_project_id} , #{db} ] should have a database flag 'log_duration' set to 'on' " do
              subject { flag }
              its('name') { should cmp 'log_duration' }
              its('value') { should cmp 'on' }
            end
          end
        end
      end
    else
      describe "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database. This test is Not Applicable." do
        skip "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database"
      end
    end
  end

  if sql_instance_names.empty?
    describe "[#{gcp_project_id}] does not have CloudSQL instances. This test is Not Applicable." do
      skip "[#{gcp_project_id}] does not have CloudSQL instances."
    end
  end
end

# 6.2.4
sub_control_id = "#{control_id}.4"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 'none'

  title "[#{control_abbrev.upcase}] Ensure 'log_statement' database flag for Cloud SQL PostgreSQL instance is set appropriately"

  desc 'The value of log_statement flag determined the SQL statements that are logged. Valid
        values are:
        - none
        - ddl
        - mod
        - all
        The value ddl logs all data definition statements. The value mod logs all ddl statements, plus
        data-modifying statements.
        The statements are logged after a basic parsing is done and statement type is determined,
        thus this does not logs statements with errors. When using extended query protocol,
        logging occurs after an Execute message is received and values of the Bind parameters are
        included.
        A value of \'ddl\' is recommended unless otherwise directed by your organization\'s logging
        policy.'
  desc 'rationale', 'Auditing helps in troubleshooting operational problems and also permits forensic analysis.
        If log_statement is not set to the correct value, too many statements may be logged leading
        to issues in finding the relevant information from the logs, or too few statements may be
        logged with relevant information missing from the logs. Setting log_statement to align with
        your organization\'s security and logging policies facilitates later auditing and review of
        database activities. This recommendation is applicable to PostgreSQL database instances.'
  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: sub_control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['AU-3']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/postgres/flags'
  ref 'GCP Docs', url: 'https://www.postgresql.org/docs/current/runtime-config-logging.html#RUNTIME-CONFIG-LOGGING-WHAT'

  sql_instance_names.each do |db|
    if sql_cache.instance_objects[db].database_version.include? 'POSTGRES'
      impact 'medium'
      if sql_cache.instance_objects[db].settings.database_flags.nil?
        describe "[#{gcp_project_id} , #{db} ] does not any have database flags." do
          subject { false }
          it { should be true }
        end
      else
        describe.one do
          sql_cache.instance_objects[db].settings.database_flags.each do |flag|
            next unless flag.name == 'log_statement'
            describe "[#{gcp_project_id} , #{db} ] should have a database flag 'log_statement' set to #{log_statement} " do
              subject { flag }
              its('name') { should cmp 'log_statement' }
              its('value') { should cmp log_statement }
            end
          end
        end
      end
    else
      describe "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database. This test is Not Applicable." do
        skip "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database"
      end
    end
  end

  if sql_instance_names.empty?
    describe "[#{gcp_project_id}] does not have CloudSQL instances. This test is Not Applicable." do
      skip "[#{gcp_project_id}] does not have CloudSQL instances."
    end
  end
end

# 6.2.5
sub_control_id = "#{control_id}.5"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 'none'

  title "[#{control_abbrev.upcase}] Ensure that the ‘Log_min_messages’ flag for a cloud SQL PostgreSQL instance is set at minimum to 'warning'"

  desc 'The log_min_messages flag defines the minimum message severity level that is considered as an error statement. Messages for error statements
        are logged with the SQL statement. Valid values include (from lowest to highest severity) DEBUG5, DEBUG4, DEBUG3, DEBUG2, DEBUG1, INFO, NOTICE,
        WARNING, ERROR, LOG, FATAL, and PANIC. Each severity level includes the subsequent levels mentioned above. ERROR is considered the best practice
        setting. Changes should only be made in accordance with the organizations logging policy'
  desc 'rationale', "Auditing helps in troubleshooting operational problems and also permits forensic analysis. If log_min_messages is not set to the
        correct value, messages may not be classified as error messages appropriately. Setting the threshold to 'Warning' will log messages for
        the most needed error messages.
        This recommendation is applicable to PostgreSQL database instances."
  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: sub_control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['AU-3']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/postgres/flags'
  ref 'GCP Docs', url: 'https://www.postgresql.org/docs/current/runtime-config-logging.html#GUC-LOG-MIN-MESSAGES'

  sql_instance_names.each do |db|
    if sql_cache.instance_objects[db].database_version.include? 'POSTGRES'
      impact 'medium'
      if sql_cache.instance_objects[db].settings.database_flags.nil?
        describe "[#{gcp_project_id} , #{db} ] does not any have database flags." do
          subject { false }
          it { should be true }
        end
      else
        describe.one do
          sql_cache.instance_objects[db].settings.database_flags.each do |flag|
            next unless flag.name == 'log_min_messages'
            describe "[#{gcp_project_id} , #{db} ] should have a database flag 'log_min_messages' set to #{log_min_messages}" do
              subject { flag }
              its('name') { should cmp 'log_min_messages' }
              its('value') { should cmp log_min_messages }
            end
          end
        end
      end
    else
      describe "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database. This test is Not Applicable." do
        skip "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database"
      end
    end
  end

  if sql_instance_names.empty?
    describe "[#{gcp_project_id}] does not have CloudSQL instances. This test is Not Applicable." do
      skip "[#{gcp_project_id}] does not have CloudSQL instances."
    end
  end
end

# 6.2.6
sub_control_id = "#{control_id}.6"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 'none'

  title "[#{control_abbrev.upcase}] Ensure ‘Log_min_error_statement’ database flag for cloud SQL PostgreSQL instance
  is set to ‘Error’ or stricter"

  desc 'The log_min_error_statement flag defines the minimum message severity level that are considered as an error statement.
        Messages for error statements are logged with the SQL statement. Valid values include (from lowest to highest severity) DEBUG5,
        DEBUG4, DEBUG3, DEBUG2, DEBUG1, INFO, NOTICE, WARNING, ERROR, LOG, FATAL, and PANIC. Each severity level includes the subsequent
        levels mentioned above. Ensure a value of ERROR or stricter is set.'
  desc 'rationale', 'Auditing helps in troubleshooting operational problems and also permits forensic analysis. If log_min_error_statement is
        not set to the correct value, messages may not be classified as error messages appropriately. Considering general log messages as error
        messages would make is difficult to find actual errors and considering only stricter severity levels as error messages may skip actual
        errors to log their SQL statements. The log_min_error_statement flag should be set to ERROR or stricter.
        This recommendation is applicable to PostgreSQL database instances.'
  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: sub_control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['AU-3']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/postgres/flags'
  ref 'GCP Docs', url: 'https://www.postgresql.org/docs/current/runtime-config-logging.html#GUC-LOG-MIN-ERROR-STATEMENT'

  sql_instance_names.each do |db|
    if sql_cache.instance_objects[db].database_version.include? 'POSTGRES'
      impact 'medium'
      if sql_cache.instance_objects[db].settings.database_flags.nil?
        describe "[#{gcp_project_id} , #{db} ] does not any have database flags." do
          subject { false }
          it { should be true }
        end
      else
        describe.one do
          sql_cache.instance_objects[db].settings.database_flags.each do |flag|
            next unless flag.name == 'log_min_error_statement'
            describe "[#{gcp_project_id} , #{db} ] should have a database flag 'log_min_error_statement' set to #{log_min_error_statement}" do
              subject { flag }
              its('name') { should cmp 'log_min_error_statement' }
              its('value') { should cmp log_min_error_statement }
            end
          end
        end
      end
    else
      describe "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database. This test is Not Applicable." do
        skip "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database"
      end
    end
  end

  if sql_instance_names.empty?
    impact 'none'
    describe "[#{gcp_project_id}] does not have CloudSQL instances. This test is Not Applicable." do
      skip "[#{gcp_project_id}] does not have CloudSQL instances."
    end
  end
end

# 6.2.7
sub_control_id = "#{control_id}.7"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 'none'

  title "[#{control_abbrev.upcase}] Ensure That the ‘Log_min_duration_statement’ Database Flag for Cloud SQL PostgreSQL
  Instance Is Set to '-1' (Disabled)"

  desc 'The log_min_duration_statement flag defines the minimum amount of execution time of a statement in milliseconds
        where the total duration of the statement is logged. Ensure that log_min_duration_statement is disabled, i.e., a
        value of -1 is set.'
  desc 'rationale', 'Logging SQL statements may include sensitive information that should not be recorded in logs. This
        recommendation is applicable to PostgreSQL database instances.'
  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: sub_control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['AU-3']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/postgres/flags'
  ref 'GCP Docs', url: 'https://www.postgresql.org/docs/current/runtime-config-logging.html#GUC-LOG-MIN-DURATION-STATEMENT'

  sql_instance_names.each do |db|
    if sql_cache.instance_objects[db].database_version.include? 'POSTGRES'
      impact 'medium'
      if sql_cache.instance_objects[db].settings.database_flags.nil?
        describe "[#{gcp_project_id} , #{db} ] does not any have database flags." do
          subject { false }
          it { should be true }
        end
      else
        describe.one do
          sql_cache.instance_objects[db].settings.database_flags.each do |flag|
            next unless flag.name == 'log_min_duration_statement'
            describe "[#{gcp_project_id} , #{db} ] should have a database flag 'log_min_duration_statement' set to '-1' " do
              subject { flag }
              its('name') { should cmp 'log_min_duration_statement' }
              its('value') { should cmp '-1' }
            end
          end
        end
      end
    else
      describe "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database. This test is Not Applicable." do
        skip "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database"
      end
    end
  end

  if sql_instance_names.empty?
    describe "[#{gcp_project_id}] does not have CloudSQL instances. This test is Not Applicable." do
      skip "[#{gcp_project_id}] does not have CloudSQL instances."
    end
  end
end

# 6.2.8
sub_control_id = "#{control_id}.8"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 'none'

  title "[#{control_abbrev.upcase}] Ensure That 'cloudsql.enable_pgaudit' Database Flag for each Cloud Sql Postgresql
  Instance Is Set to 'on' For Centralized Logging"

  desc 'Ensure cloudsql.enable_pgaudit database flag for Cloud SQL PostgreSQL instance is set to on to allow for centralized logging.'
  desc 'rationale', 'As numerous other recommendations in this section consist of turning on flags for logging purposes, your organization
        will need a way to manage these logs. You may have a solution already in place. If you do not, consider installing and enabling the
        open source pgaudit extension within PostgreSQL and enabling its corresponding flag of cloudsql.enable_pgaudit. This flag and
        installing the extension enables database auditing in PostgreSQL through the open-source pgAudit extension. This extension provides
        detailed session and object logging to comply with government, financial, & ISO standards and provides auditing capabilities to
        mitigate threats by monitoring security events on the instance. Enabling the flag and settings later in this recommendation will send
        these logs to Google Logs Explorer so that you can access them in a central location. to This recommendation is applicable only to
        PostgreSQL database instances.'
  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: sub_control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['AU-3']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/postgres/flags#list-flags-postgres'
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/postgres/pg-audit#enable-auditing-flag'
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/postgres/pg-audit#customizing-database-audit-logging'
  ref 'GCP Docs', url: 'https://cloud.google.com/logging/docs/audit/configure-data-access#config-console-enable'

  sql_instance_names.each do |db|
    if sql_cache.instance_objects[db].database_version.include? 'POSTGRES'
      impact 'medium'
      if sql_cache.instance_objects[db].settings.database_flags.nil?
        describe "[#{gcp_project_id} , #{db} ] does not any have database flags." do
          subject { false }
          it { should be true }
        end
      else
        describe.one do
          sql_cache.instance_objects[db].settings.database_flags.each do |flag|
            next unless flag.name == 'enable_pgaudit'
            describe "[#{gcp_project_id} , #{db} ] should have a database flag 'enable_pgaudit' set to 'on'" do
              subject { flag }
              its('name') { should cmp 'enable_pgaudit' }
              its('value') { should cmp 'on' }
            end
          end
        end
      end
    else
      describe "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database. This test is Not Applicable." do
        skip "[#{gcp_project_id}] [#{db}] is not a PostgreSQL database"
      end
    end
  end

  if sql_instance_names.empty?
    describe "[#{gcp_project_id}] does not have CloudSQL instances. This test is Not Applicable." do
      skip "[#{gcp_project_id}] does not have CloudSQL instances."
    end
  end
end
