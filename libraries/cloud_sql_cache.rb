# frozen_string_literal: true

# Copyright 2020 Google LLC
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

require 'gcp_base_cache'

# Cache for Cloud SQL Instances.
#
class CloudSQLCache < GCPBaseCache
  name 'CloudSQLCache'
  desc 'The Cloud SQL cache resource contains functions consumed by
       the CIS/PCI Google profiles:
       https://github.com/GoogleCloudPlatform/inspec-gcp-cis-benchmark'

  @@cached_sql_instance_names = []
  @@cached_sql_instance_objects = {}
  @@cache_set = false

  def initialize(params = {})
    super(params) # Pass all parameters to the parent class
    @gcp_project_id = params[:project] # Extract the project from the params hash
  end

  def instance_names
    set_sql_cache unless cache_set?
    @@cached_sql_instance_names
  end

  def instance_objects
    set_sql_cache unless cache_set?
    @@cached_sql_instance_objects
  end

  def cache_set?
    @@cache_set
  end

  private

  def set_sql_cache
    @@cached_sql_instance_names = []
    @@cached_sql_instance_objects = {}
    inspec.google_sql_database_instances(project: @gcp_project_id)
          .instance_names.each do |instance_name|
      @@cached_sql_instance_names.push(instance_name)
      @@cached_sql_instance_objects[instance_name] = inspec
                                                     .google_sql_database_instance(project: @gcp_project_id,
                                                                                   database: instance_name)
    end
    @@cache_set = true
  end
end
