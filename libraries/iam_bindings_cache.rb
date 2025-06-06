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

# Cache for IAM Bindings and roles.
#
class IAMBindingsCache < GCPBaseCache
  name 'IAMBindingsCache'
  desc 'The IAM Bindings cache resource contains functions consumed by
       the CIS/PCI Google profiles:
       https://github.com/GoogleCloudPlatform/inspec-gcp-cis-benchmark'

  @@cached_iam_binding_roles = []
  @@cached_iam_bindings = {}
  @@iam_bindings_cache_set = false
  @@iam_binding_roles_cache_set = false

  def initialize(params = {})
    super(params) # Pass all parameters to the parent class
    @gcp_project_id = params[:project] # Extract the project from the params hash
  end

  def iam_binding_roles
    set_iam_binding_roles_cache unless iam_binding_roles_cache_set?
    @@cached_iam_binding_roles
  end

  def iam_bindings
    set_iam_bindings_cache unless iam_bindings_cache_set?
    @@cached_iam_bindings
  end

  def iam_bindings_cache_set?
    @@iam_bindings_cache_set
  end

  def iam_binding_roles_cache_set?
    @@iam_binding_roles_cache_set
  end

  private

  def set_iam_binding_roles_cache
    @@cached_iam_binding_roles =
      inspec.google_project_iam_bindings(project: @gcp_project_id)
            .iam_binding_roles
    @@iam_binding_roles_cache_set = true
  end

  def set_iam_bindings_cache
    @@cached_iam_bindings = {}
    iam_binding_roles.each do |iam_binding_role|
      @@cached_iam_bindings[iam_binding_role] =
        inspec.google_project_iam_binding(project: @gcp_project_id,
                                          role: iam_binding_role)
    end
    @@iam_bindings_cache_set = true
  end
end
