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

# Cache for Service Accounts.
#
class ServiceAccountCache < GCPBaseCache
  name 'ServiceAccountCache'
  desc 'The Service Account cache resource contains functions consumed by
       the CIS/PCI Google profiles:
       https://github.com/GoogleCloudPlatform/inspec-gcp-cis-benchmark'

  @@cached_service_account_emails = []
  @@cached_service_account_keys = {}
  @@sa_email_cache_set = false
  @@sa_keys_cache_set = false

  def initialize(params = {})
    super(params) # Pass all parameters to the parent class
    @gcp_project_id = params[:project] # Extract the project from the params hash
  end

  def service_account_emails
    set_service_account_emails_cache unless sa_email_cache_set?
    @@cached_service_account_emails
  end

  def service_account_keys
    set_service_account_keys_cache unless sa_keys_cache_set?
    @@cached_service_account_keys
  end

  def sa_email_cache_set?
    @@sa_email_cache_set
  end

  def sa_keys_cache_set?
    @@sa_keys_cache_set
  end

  private

  def set_service_account_emails_cache
    @@cached_service_account_emails =
      inspec.google_service_accounts(project: @gcp_project_id)
            .service_account_emails
    @@sa_email_cache_set = true
  end

  def set_service_account_keys_cache
    @@cached_service_account_keys = {}
    service_account_emails.each do |sa_email|
      @@cached_service_account_keys[sa_email] =
        inspec.google_service_account_keys(project: @gcp_project_id,
                                           service_account: sa_email)
    end
    @@sa_keys_cache_set = true
  end
end
