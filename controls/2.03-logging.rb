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

title 'Ensure that object versioning is enabled on log-buckets'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "2.3"
control_abbrev = "logging"

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure that object versioning is enabled on log-buckets"

  desc "It is recommended to enable object versioning on log-buckets."
  desc "rationale", "Logs can be exported by creating one or more sinks that include a logs filter and a destination. As Stackdriver Logging receives new log entries, they are compared against each sink. If a log entry matches a sink's filter, then a copy of the log entry is written to the destination.

Sinks can be configured to export logs in Storage buckets. To support the retrieval of objects that are deleted or overwritten, Object Versioning feature should be enabled on all such storage buckets where sinks are configured."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/storage/docs/object-versioning"

  google_logging_project_sinks(project: gcp_project_id).where(sink_destination: /storage.googleapis.com/).sink_destinations.each do |sink|
    bucket = sink.split("/").last
    describe "[#{gcp_project_id}] Logging bucket #{bucket}" do
      subject { google_storage_bucket(name: bucket) }
      it { should have_versioning_enabled }
    end
  end
end
