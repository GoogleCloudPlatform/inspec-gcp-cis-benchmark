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

# Cache for KMS Crypto Keys and Key Rings.
#
class KMSKeyCache < GCPBaseCache
  name 'KMSKeyCache'
  desc 'The KMS Key cache resource contains functions consumed by
       the CIS/PCI Google profiles:
       https://github.com/GoogleCloudPlatform/inspec-gcp-cis-benchmark'
  attr_reader :kms_locations

  @@cached_kms_key_ring_names = {}
  @@cached_kms_crypto_keys = {}
  @@kms_key_ring_names_cache_set = false
  @@kms_crypto_key_cache_set = false
  @kms_locations = []

  def initialize(params = {})
    super(params) # Pass all parameters to the parent class
    @gcp_project_id = params[:project] # Extract the project from the params hash
    @kms_locations = params[:locations] # Extract the locations from the params hash
  end

  def kms_key_ring_names
    set_kms_key_ring_names_cache unless kms_key_ring_names_cache_set?
    @@cached_kms_key_ring_names
  end

  def kms_crypto_keys
    set_kms_crypto_key_cache unless kms_crypto_key_cache_set?
    @@cached_kms_crypto_keys
  end

  def kms_key_ring_names_cache_set?
    @@kms_key_ring_names_cache_set
  end

  def kms_crypto_key_cache_set?
    @@kms_crypto_key_cache_set
  end

  private

  def set_kms_key_ring_names_cache
    @@cached_kms_key_ring_names = {}
    @kms_locations.each do |location|
      @@cached_kms_key_ring_names[location] =
        inspec.google_kms_key_rings(project: @gcp_project_id,
                                    location: location)
              .key_ring_names
    end
    @@kms_key_ring_names_cache_set = true
  end

  def set_kms_crypto_key_cache
    @@cached_kms_crypto_keys = {}

    @kms_locations.each do |location|
      kms_keys_per_location = {}
      kms_key_ring_names[location].each do |keyring|
        kms_keys_per_location[keyring] =
          inspec.google_kms_crypto_keys(project: @gcp_project_id,
                                        location: location,
                                        key_ring_name: keyring)
                .crypto_key_names
      end
      @@cached_kms_crypto_keys[location] = kms_keys_per_location
    end
    @@kms_crypto_key_cache_set = true
  end
end
