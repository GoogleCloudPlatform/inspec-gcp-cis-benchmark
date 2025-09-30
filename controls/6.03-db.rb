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

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '6.3'
control_abbrev = 'db'

sql_cache = CloudSQLCache(project: gcp_project_id)
sql_instance_names = sql_cache.instance_names

# 6.3.1
sub_control_id = "#{control_id}.1"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 'none'

  title "[#{control_abbrev.upcase}] Ensure 'external scripts enabled' Database Flag for Cloud SQL SQL Server Instance Is Set to 'off'"

  desc 'It is recommended to set external scripts enabled database flag for Cloud SQL SQL Server instance to off'
  desc 'rationale', 'external scripts enabled enable the execution of scripts with certain remote language extensions. This property is
        OFF by default. When Advanced Analytics Services is installed, setup can optionally set this property to true. As the External Scripts
        Enabled feature allows scripts external to SQL such as files located in an R library to be executed, which could adversely affect the
        security of the system, hence this should be disabled. This recommendation is applicable to SQL Server database instances.'

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: sub_control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['CM-7']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/external-scripts-enabled-server-configuration-option?view=sql-server-ver15'
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/sqlserver/flags'
  ref 'GCP Docs', url: 'https://docs.microsoft.com/en-us/sql/advanced-analytics/concepts/security?view=sql-server-ver15'
  ref 'GCP Docs', url: 'https://www.stigviewer.com/stig/ms_sql_server_2016_instance/2018-03-09/finding/V-79347'

  sql_instance_names.each do |db|
    if sql_cache.instance_objects[db].database_version.include? 'SQLSERVER'
      impact 'medium'
      if sql_cache.instance_objects[db].settings.database_flags.nil?
        describe "[#{gcp_project_id} , #{db} ] does not any have database flags." do
          subject { false }
          it { should be true }
        end
      else
        describe.one do
          sql_cache.instance_objects[db].settings.database_flags.each do |flag|
            next unless flag.name == 'external scripts enabled'
            describe "[#{gcp_project_id} , #{db} ] should have a database flag 'external scripts enabled' set to 'off' " do
              subject { flag }
              its('name') { should cmp 'external scripts enabled' }
              its('value') { should cmp 'off' }
            end
          end
        end
      end
    else
      describe "[#{gcp_project_id}] [#{db}] is not a SQL Server database. This test is Not Applicable." do
        skip "[#{gcp_project_id}] [#{db}] is not a SQL Server database"
      end
    end
  end

  if sql_instance_names.empty?
    describe 'There are no Cloud SQL Instances in this project. This test is Not Applicable.' do
      skip 'There are no Cloud SQL Instances in this project'
    end
  end
end

# 6.3.2
sub_control_id = "#{control_id}.2"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 'none'

  title "[#{control_abbrev.upcase}] Ensure 'cross db ownership chaining' Database Flag for Cloud SQL SQL Server Instance Is Set to 'off'"

  desc 'It is recommended to set cross db ownership chaining database flag for Cloud SQL SQL Server instance to off.
        This flag is deprecated for all SQL Server versions in CGP. Going forward, you cant set its value to on. However, if you have this
        flag enabled, we strongly recommend that you either remove the flag from your database or set it to off. For cross-database access,
        use the Microsoft tutorial for signing stored procedures with a certificate.'
  desc 'rationale', 'Use the cross db ownership for chaining option to configure cross-database ownership chaining for an instance of Microsoft
        SQL Server. This server option allows you to control cross-database ownership chaining at the database level or to allow cross-database
        ownership chaining for all databases. Enabling cross db ownership is not recommended unless all of the databases hosted by the instance
        of SQL Server must participate in cross-database ownership chaining and you are aware of the security implications of this setting. This
        recommendation is applicable to SQL Server database instances.'

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: sub_control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['AC-3']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/sqlserver/flags'
  ref 'GCP Docs', url: 'https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/cross-db-ownership-chaining-server-configuration-option?view=sql-server-ver15'

  sql_instance_names.each do |db|
    if sql_cache.instance_objects[db].database_version.include? 'SQLSERVER'
      impact 'medium'
      if sql_cache.instance_objects[db].settings.database_flags.nil?
        describe "[#{gcp_project_id} , #{db} ] does not any have database flags." do
          subject { false }
          it { should be true }
        end
      else
        describe.one do
          sql_cache.instance_objects[db].settings.database_flags.each do |flag|
            next unless flag.name == 'cross db ownership chaining'
            describe "[#{gcp_project_id} , #{db} ] should have a database flag 'cross db ownership chaining' set to 'off' " do
              subject { flag }
              its('name') { should cmp 'cross db ownership chaining' }
              its('value') { should cmp 'off' }
            end
          end
        end
      end
    else
      describe "[#{gcp_project_id}] [#{db}] is not a SQL Server database. This test is Not Applicable." do
        skip "[#{gcp_project_id}] [#{db}] is not a SQL Server database"
      end
    end
  end

  if sql_instance_names.empty?
    impact 'none'
    describe 'There are no Cloud SQL Instances in this project. This test is Not Applicable.' do
      skip 'There are no Cloud SQL Instances in this project'
    end
  end
end

# 6.3.3
sub_control_id = "#{control_id}.3"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 'none'

  title "[#{control_abbrev.upcase}] Ensure 'user Connections' Database Flag for Cloud SQL SQL Server Instance Is Set to a Non-limiting Value"

  desc 'It is recommended to check the user connections for a Cloud SQL SQL Server instance to ensure that it is not artificially limiting connections.'
  desc 'rationale', 'The user connections option specifies the maximum number of simultaneous user connections that are allowed on an instance of SQL
        Server. The actual number of user connections allowed also depends on the version of SQL Server that you are using, and also the limits of your
        application or applications and hardware. SQL Server allows a maximum of 32,767 user connections. Because user connections is by default a
        self-configuring value, with SQL Server adjusting the maximum number of user connections automatically as needed, up to the maximum value
        allowable. For example, if only 10 users are logged in, 10 user connection objects are allocated. In most cases, you do not have to change the
        value for this option. The default is 0, which means that the maximum (32,767) user connections are allowed. However if there is a number defined
        here that limits connections, SQL Server will not allow anymore above this limit. If the connections are at the limit, any new requests will be
        dropped, potentially causing lost data or outages for those using the database.'

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: sub_control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['AC-2']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/sqlserver/flags'
  ref 'GCP Docs', url: 'https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/configure-the-user-connections-server-configuration-option?view=sql-server-ver15'
  ref 'GCP Docs', url: 'https://www.stigviewer.com/stig/ms_sql_server_2016_instance/2018-03-09/finding/V-79119'

  sql_instance_names.each do |db|
    if sql_cache.instance_objects[db].database_version.include? 'SQLSERVER'
      impact 'medium'
      if sql_cache.instance_objects[db].settings.database_flags.nil?
        describe "[#{gcp_project_id} , #{db} ] does not any have database flags." do
          subject { false }
          it { should be true }
        end
      else
        describe.one do
          sql_cache.instance_objects[db].settings.database_flags.each do |flag|
            next unless flag.name == 'user connections'
            describe "[#{gcp_project_id} , #{db} ] should have a database flag 'user connections' set to #{user_connections} " do
              subject { flag }
              its('name') { should cmp 'user connections' }
              its('value') { should cmp user_connections }
            end
          end
        end
      end
    else
      describe "[#{gcp_project_id}] [#{db}] is not a SQL Server database. This test is Not Applicable." do
        skip "[#{gcp_project_id}] [#{db}] is not a SQL Server database"
      end
    end
  end

  if sql_instance_names.empty?
    describe 'There are no Cloud SQL Instances in this project. This test is Not Applicable.' do
      skip 'There are no Cloud SQL Instances in this project'
    end
  end
end

# 6.3.4
sub_control_id = "#{control_id}.4"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 'none'

  title "[#{control_abbrev.upcase}] Ensure 'user options' Database Flag for Cloud SQL SQL Server Instance Is Not Configured"

  desc 'The user options option specifies global defaults for all users. A list of default query processing options is established
        for the duration of a users work session. The user options option allows you to change the default values of the SET options (if the
        servers default settings are not appropriate).
        A user can override these defaults by using the SET statement. You can configure user options dynamically for new logins. After you
        change the setting of user options, new login sessions use the new setting; current login sessions are not affected. This recommendation
        is applicable to SQL Server database instances.'
  desc 'rationale', 'It is recommended that, user options database flag for Cloud SQL SQL Server instance should not be configured.
        A user can override these defaults set with user options by using the SET statement. Some of these features/options could adversely
        affect the security of the system if enabled.'

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: sub_control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['CM-6']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/sqlserver/flags'
  ref 'GCP Docs', url: 'https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/configure-the-user-options-server-configuration-option?view=sql-server-ver15'
  ref 'GCP Docs', url: 'https://www.stigviewer.com/stig/ms_sql_server_2016_instance/2018-03-09/finding/V-79335'

  sql_instance_names.each do |db|
    if sql_cache.instance_objects[db].database_version.include? 'SQLSERVER'
      impact 'medium'
      if sql_cache.instance_objects[db].settings.database_flags.nil?
        describe "[#{gcp_project_id} , #{db} ] does not any have database flags." do
          subject { false }
          it { should be true }
        end
      else
        describe.one do
          sql_cache.instance_objects[db].settings.database_flags.each do |flag|
            next unless flag.name == 'user options'
            describe "[#{gcp_project_id} , #{db} ] should not have database flag 'user options' configured" do
              subject { false }
              it { should be true }
            end
          end
        end
      end
    else
      describe "[#{gcp_project_id}] [#{db}] is not a SQL Server database. This test is Not Applicable." do
        skip "[#{gcp_project_id}] [#{db}] is not a SQL Server database"
      end
    end
  end

  if sql_instance_names.empty?
    describe 'There are no Cloud SQL Instances in this project. This test is Not Applicable.' do
      skip 'There are no Cloud SQL Instances in this project'
    end
  end
end

# 6.3.5
sub_control_id = "#{control_id}.5"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 'none'

  title "[#{control_abbrev.upcase}] Ensure 'remote access' Database Flag for Cloud SQL SQL Server Instance Is Set to 'off'"

  desc 'It is recommended to set remote access database flag for Cloud SQL SQL Server instance to off.'
  desc 'rationale', 'The remote access option controls the execution of stored procedures from local or remote servers on
        which instances of SQL Server are running. This default value for this option is 1. This grants permission to run local
        stored procedures from remote servers or remote stored procedures from the local server. To prevent local stored procedures
        from being run from a remote server or remote stored procedures from being run on the local server, this must be disabled.
        The Remote Access option controls the execution of local stored procedures on remote servers or remote stored procedures on
        local server. Remote access functionality can be abused to launch a Denial-of-Service (DoS) attack on remote servers by
        off-loading query processing to a target, hence this should be disabled. This recommendation is applicable to SQL Server database instances.'

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: sub_control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['CM-7']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/sqlserver/flags'
  ref 'GCP Docs', url: 'https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/configure-the-remote-access-server-configuration-option?view=sql-server-ver15'
  ref 'GCP Docs', url: 'https://www.stigviewer.com/stig/ms_sql_server_2016_instance/2018-03-09/finding/V-79337'

  sql_instance_names.each do |db|
    if sql_cache.instance_objects[db].database_version.include? 'SQLSERVER'
      impact 'medium'
      if sql_cache.instance_objects[db].settings.database_flags.nil?
        describe "[#{gcp_project_id} , #{db} ] does not any have database flags." do
          subject { false }
          it { should be true }
        end
      else
        describe.one do
          sql_cache.instance_objects[db].settings.database_flags.each do |flag|
            next unless flag.name == 'remote access'
            describe "[#{gcp_project_id} , #{db} ] should have a database flag 'remote access' set to 'off' " do
              subject { flag }
              its('name') { should cmp 'remote access' }
              its('value') { should cmp 'off' }
            end
          end
        end
      end
    else
      describe "[#{gcp_project_id}] [#{db}] is not a SQL Server database. This test is Not Applicable." do
        skip "[#{gcp_project_id}] [#{db}] is not a SQL Server database"
      end
    end
  end

  if sql_instance_names.empty?
    describe 'There are no Cloud SQL Instances in this project. This test is Not Applicable.' do
      skip 'There are no Cloud SQL Instances in this project'
    end
  end
end

# 6.3.6
sub_control_id = "#{control_id}.6"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 'none'

  title "[#{control_abbrev.upcase}] Ensure '3625 (trace flag)' Database Flag for all Cloud SQL SQL Server Instances Is Set to 'on'"

  desc 'It is recommended to set 3625 (trace flag) database flag for Cloud SQL SQL Server instance to on.'
  desc 'rationale', 'Microsoft SQL Trace Flags are frequently used to diagnose performance issues or to debug stored procedures or
        complex computer systems, but they may also be recommended by Microsoft Support to address behavior that is negatively impacting a
        specific workload. All documented trace flags and those recommended by Microsoft Support are fully supported in a production
        environment when used as directed. 3625(trace log) Limits the amount of information returned to users who are not members of the
        sysadmin fixed server role, by masking the parameters of some error messages using \'******\'. Setting this in a Google Cloud flag for
        the instance allows for security through obscurity and prevents the disclosure of sensitive information, hence this is recommended to
        set this flag globally to on to prevent the flag having been left off, or changed by bad actors. This recommendation is applicable to
        SQL Server database instances.'

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: sub_control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['SC-1']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/sqlserver/flags'
  ref 'GCP Docs', url: 'https://docs.microsoft.com/en-us/sql/t-sql/database-console-commands/dbcc-traceon-trace-flags-transact-sql?view=sql-server-ver15#trace-flags'
  ref 'GCP Docs', url: 'https://github.com/ktaranov/sqlserver-kit/blob/master/SQL%20Server%20Trace%20Flag.md'

  sql_instance_names.each do |db|
    if sql_cache.instance_objects[db].database_version.include? 'SQLSERVER'
      impact 'medium'
      if sql_cache.instance_objects[db].settings.database_flags.nil?
        describe "[#{gcp_project_id} , #{db} ] does not any have database flags." do
          subject { false }
          it { should be true }
        end
      else
        describe.one do
          sql_cache.instance_objects[db].settings.database_flags.each do |flag|
            next unless flag.name == '3625'
            describe "[#{gcp_project_id} , #{db} ] should have a database flag '3625' set to 'off' " do
              subject { flag }
              its('name') { should cmp '3625' }
              its('value') { should cmp 'off' }
            end
          end
        end
      end
    else
      impact 'none'
      describe "[#{gcp_project_id}] [#{db}] is not a SQL Server database. This test is Not Applicable." do
        skip "[#{gcp_project_id}] [#{db}] is not a SQL Server database"
      end
    end
  end

  if sql_instance_names.empty?
    describe 'There are no Cloud SQL Instances in this project. This test is Not Applicable.' do
      skip 'There are no Cloud SQL Instances in this project'
    end
  end
end

# 6.3.7
sub_control_id = "#{control_id}.7"
control "cis-gcp-#{sub_control_id}-#{control_abbrev}" do
  impact 'none'

  title "[#{control_abbrev.upcase}] Ensure 'contained database authentication' Database Flag for Cloud SQL SQL Server Instance Is Set to 'off'"

  desc 'A contained database includes all database settings and metadata required to define the database and has no configuration dependencies
        on the instance of the Database Engine where the database is installed. Users can connect to the database without authenticating a login
        at the Database Engine level. Isolating the database from the Database Engine makes it possible to easily move the database to another
        instance of SQL Server. Contained databases have some unique threats that should be understood and mitigated by SQL Server Database Engine
        administrators. Most of the threats are related to the USER WITH PASSWORD authentication process, which moves the authentication boundary
        from the Database Engine level to the database level, hence this is recommended not to enable this flag. This recommendation is applicable
        to SQL Server database instances.'
  desc 'rationale', 'When contained databases are enabled, database users with the ALTER ANY USER permission, such as members of the db_owner and
        db_accessadmin database roles, can grant access to databases and by doing so, grant access to the instance of SQL Server. This means that
        control over access to the server is no longer limited to members of the sysadmin and securityadmin fixed server role, and logins with the
        server level CONTROL SERVER and ALTER ANY LOGIN permission.
        It is recommended to set contained database authentication database flag for Cloud SQL on the SQL Server instance to off.'

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: sub_control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['AC-3']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/sql/docs/sqlserver/flags'
  ref 'GCP Docs', url: 'https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/contained-database-authentication-server-configuration-option?view=sql-server-ver15'
  ref 'GCP Docs', url: 'https://docs.microsoft.com/en-us/sql/relational-databases/databases/security-best-practices-with-contained-databases?view=sql-server-ver15'

  sql_instance_names.each do |db|
    if sql_cache.instance_objects[db].database_version.include? 'SQLSERVER'
      impact 'medium'
      if sql_cache.instance_objects[db].settings.database_flags.nil?
        describe "[#{gcp_project_id} , #{db} ] does not any have database flags." do
          subject { false }
          it { should be true }
        end
      else
        describe.one do
          sql_cache.instance_objects[db].settings.database_flags.each do |flag|
            next unless flag.name == 'contained database authentication'
            describe "[#{gcp_project_id} , #{db} ] should have a database flag 'contained database authentication' set to 'off' " do
              subject { flag }
              its('name') { should cmp 'contained database authentication' }
              its('value') { should cmp 'off' }
            end
          end
        end
      end
    else
      describe "[#{gcp_project_id}] [#{db}] is not a SQL Server database. This test is Not Applicable." do
        skip "[#{gcp_project_id}] [#{db}] is not a SQL Server database"
      end
    end
  end

  if sql_instance_names.empty?
    describe "[#{gcp_project_id}] does not have CloudSQL instances. This test is Not Applicable." do
      skip "[#{gcp_project_id}] does not have CloudSQL instances."
    end
  end
end
