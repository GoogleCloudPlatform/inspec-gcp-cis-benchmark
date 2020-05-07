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

title 'Ensure log metric filter and alerts exists for VPC network changes'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "2.9"
control_abbrev = "logging"

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure log metric filter and alerts exists for VPC network changes "

  desc "It is recommended that a metric filter and alarm be established for VPC network changes."
  desc "rationale", "It is possible to have more than 1 VPC within an project, in addition it is also possible to create a peer connection between 2 VPCs enabling network traffic to route between VPCs.

Monitoring changes to VPC will help ensure VPC traffic flow is not getting impacted."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/logging/docs/logs-based-metrics/"
  ref "GCP Docs", url: "https://cloud.google.com/monitoring/custom-metrics/"
  ref "GCP Docs", url: "https://cloud.google.com/monitoring/alerts/"
  ref "GCP Docs", url: "https://cloud.google.com/logging/docs/reference/tools/gcloud-logging"
  ref "GCP Docs", url: "https://cloud.google.com/vpc/docs/overview"

  log_filter = "resource.type=gce_network AND jsonPayload.event_subtype=\"compute.networks.insert\" OR jsonPayload.event_subtype=\"compute.networks.patch\" OR jsonPayload.event_subtype=\"compute.networks.delete\" OR jsonPayload.event_subtype=\"compute.networks.removePeering\" OR jsonPayload.event_subtype=\"compute.networks.addPeering\""
  describe "[#{gcp_project_id}] VPC Network changes filter" do
    subject { google_project_metrics(project: gcp_project_id).where(metric_filter: log_filter) }
    it { should exist }
  end

  google_project_metrics(project: gcp_project_id).where(metric_filter: log_filter).metric_types.each do |metrictype|
    describe.one do
      filter = "metric.type=\"#{metrictype}\" resource.type=\"audited_resource\""
      google_project_alert_policies(project: gcp_project_id).where(policy_enabled_state: true).policy_names.each do |policy|
        condition = google_project_alert_policy_condition(policy: policy, filter: filter)
        describe "[#{gcp_project_id}] VPC Network changes alert policy" do
          subject { condition }
          it { should exist }
          its('aggregation_cross_series_reducer') { should eq 'REDUCE_COUNT' }
          its('aggregation_per_series_aligner') { should eq 'ALIGN_RATE' }
          its('condition_threshold_value') { should eq 0.001 }
          its('aggregation_alignment_period') { should eq '60s' }
        end
      end
    end
  end
end
