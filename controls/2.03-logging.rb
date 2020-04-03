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

title 'Ensure that retention policies on log buckets are configured using Bucket Lock'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "2.3"
control_abbrev = "logging"

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure that retention policies on log buckets are configured using Bucket Lock"

  desc "It is recommended to set up retention policies and configure Bucket Lock on all storage buckets that are used as log sinks."
  desc "rationale", "Logs can be exported by creating one or more sinks that include a log filter and a destination. As Stackdriver Logging receives new log entries, they are compared against each sink. If a log entry matches a sink's filter, then a copy of the log entry is written to the destination.

Sinks can be configured to export logs in storage buckets. It is recommended to configure a data retention policy for these cloud storage buckets and to lock the data retention policy; thus permanently preventing the policy from being reduced or removed. This way, if the system is ever compromised by an attacker or a malicious insider who wants to cover their tracks, the activity logs are definitely preserved for forensics and security investigations."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/storage/docs/bucket-lock"

  google_logging_project_sinks(project: gcp_project_id).where(sink_destination: /storage.googleapis.com/).sink_destinations.each do |sink|
    bucket = sink.split("/").last
    describe "[#{gcp_project_id}] Logging bucket #{bucket} retention policy Bucket Lock status" do
      subject { google_storage_bucket(name: bucket).retention_policy }
      its('is_locked') {should be true}
    end
  end
end
