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

title 'Ensure that sinks are configured for all Log entries'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '2.2'
control_abbrev = 'logging'

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'low'

  title "[#{control_abbrev.upcase}] Ensure that sinks are configured for all Log entries"

  desc 'It is recommended to create a sink that will export copies of all the log entries. This can help aggregate logs from multiple projects and export them to a Security Information and Event Management (SIEM).'
  desc 'rationale', 'Log entries are held in Cloud Logging. To aggregate logs, export them to a SIEM. To keep them longer, it is recommended to set up a log sink. Exporting involves writing a filter that selects the log entries to export, and choosing a destination in Cloud Storage, BigQuery, or Cloud Pub/Sub. The filter and destination are held in an object called a sink. To ensure all log entries are exported to sinks, ensure that there is no filter configured for a sink. Sinks can be created in projects, organizations, folders, and billing accounts.'

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: %w[AU-4 AU-12]

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/logging/docs/reference/tools/gcloud-logging'
  ref 'GCP Docs', url: 'https://cloud.google.com/logging/quotas'
  ref 'GCP Docs', url: 'https://cloud.google.com/logging/docs/export/'
  ref 'GCP Docs', url: 'https://cloud.google.com/logging/docs/export/using_exported_logs'
  ref 'GCP Docs', url: 'https://cloud.google.com/logging/docs/export/configure_export_v2'
  ref 'GCP Docs', url: 'https://cloud.google.com/logging/docs/export/aggregated_exports'
  ref 'GCP Docs', url: 'https://cloud.google.com/sdk/gcloud/reference/beta/logging/sinks/list'

  empty_filter_sinks = []
  google_logging_project_sinks(project: gcp_project_id).names.each do |sink_name|
    empty_filter_sinks.push(sink_name) if google_logging_project_sink(project: gcp_project_id,
                                                                      name: sink_name).filter.nil?
  end
  describe "[#{gcp_project_id}] Project level Log sink with an empty filter" do
    subject { empty_filter_sinks }
    it 'is expected to exist' do
      expect(empty_filter_sinks.count).to be_positive
    end
  end
end
