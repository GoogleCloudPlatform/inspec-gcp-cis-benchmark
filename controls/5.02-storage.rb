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

title 'Ensure that there are no publicly accessible objects in storage buckets'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "5.2"
control_abbrev = "storage"

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure that there are no publicly accessible objects in storage buckets"

  desc "It is recommended that storage object ACL should not grant access to 'allUsers'."
  desc "rationale", "Allowing public access to objects allows anyone with an internet connection to access sensitive data that is important to your business. IAM is used to control access over an entire bucket however to customize access to individual objects within a bucket ACLs are used. Even if IAM applied on storage does not allow access to 'allUsers' there could be object specific ACLs that allows public access to the specific objects inside the bucket.  Hence it is important to check ACLs at individual object level."

  tag cis_scored: false
  tag cis_level: 1
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/storage/docs/access-control/create-manage-lists"

end
