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

title 'Ensure log metric filter and alerts exists for Custom Role changes'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "2.6"
control_abbrev = "logging"

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure log metric filter and alerts exists for Custom Role changes"

  desc "It is recommended that a metric filter and alarm be established for changes IAM Role creation, deletion and updating activities."
  desc "rationale", "Google Cloud Identity and Access Management (Cloud IAM) provides predefined roles that give granular access to specific Google Cloud Platform resources and prevent unwanted access to other resources. However to cater organization specific needs, Cloud IAM also provides ability to create custom roles. Project Owner and administrators with Organization Role Administrator role or the IAM Role Administrator role can create custom roles. Monitoring role creation, deletion and updating activities will help in identifying over-privileged role at early stages."

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
  ref "GCP Docs", url: "https://cloud.google.com/iam/docs/understanding-custom-roles"

  log_filter = "resource.type=\"iam_role\" AND protoPayload.methodName=\"google.iam.admin.v1.CreateRole\" OR protoPayload.methodName=\"google.iam.admin.v1.DeleteRole\" OR protoPayload.methodName=\"google.iam.admin.v1.UpdateRole\""
  describe "[#{gcp_project_id}] Custom Role changes filter" do
    subject { google_project_metrics(project: gcp_project_id).where(metric_filter: log_filter) }
    it { should exist }
  end

  google_project_metrics(project: gcp_project_id).where(metric_filter: log_filter).metric_types.each do |metrictype|
    describe.one do
      filter = "metric.type=\"#{metrictype}\" resource.type=\"audited_resource\""
      google_project_alert_policies(project: gcp_project_id).where(policy_enabled_state: true).policy_names.each do |policy|
        condition = google_project_alert_policy_condition(policy: policy, filter: filter)
        describe "[#{gcp_project_id}] Custom Role changes alert policy" do
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
