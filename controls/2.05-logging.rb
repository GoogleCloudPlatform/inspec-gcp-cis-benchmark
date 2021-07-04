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

title 'Ensure log metric filter and alerts exists for Audit Configuration Changes'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '2.5'
control_abbrev = 'logging'

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'low'

  title "[#{control_abbrev.upcase}] Ensure log metric filter and alerts exists for Audit Configuration Changes"

  desc "Google Cloud Platform services write audit log entries to Admin Activity and Data Access logs to helps answer the questions of 'who did what, where, and when?' within Google Cloud Platform projects. Cloud Audit logging records information includes the identity of the API caller, the time of the API call, the source IP address of the API caller, the request parameters, and the response elements returned by the GCP services. Cloud Audit logging provides a history of AWS API calls for an account, including API calls made via the Console, SDKs, command line tools, and other GCP services."
  desc 'rationale', 'Admin activity and Data access logs produced by Cloud audit logging enables security analysis, resource change tracking, and compliance auditing. Configuring metric filter and alerts for Audit Configuration Changes ensures recommended state of audit configuration and hence, all the activities in project are audit-able at any point in time.'

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ["AU-3", "AU-12"]

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/logging/docs/logs-based-metrics/'
  ref 'GCP Docs', url: 'https://cloud.google.com/monitoring/custom-metrics/'
  ref 'GCP Docs', url: 'https://cloud.google.com/monitoring/alerts/'
  ref 'GCP Docs', url: 'https://cloud.google.com/logging/docs/reference/tools/gcloud-logging'
  ref 'GCP Docs', url: 'https://cloud.google.com/logging/docs/audit/configure-data-access#getiampolicy-setiampolicy'

  log_filter = 'resource.type=audited_resource AND protoPayload.methodName="SetIamPolicy" AND protoPayload.serviceData.policyDelta.auditConfigDeltas:*'
  describe "[#{gcp_project_id}] Audit configuration changes filter" do
    subject { google_project_metrics(project: gcp_project_id).where(metric_filter: log_filter) }
    it { should exist }
  end

  google_project_metrics(project: gcp_project_id).where(metric_filter: log_filter).metric_types.each do |metrictype|
    describe.one do
      filter = "metric.type=\"#{metrictype}\" resource.type=\"audited_resource\""
      google_project_alert_policies(project: gcp_project_id).where(policy_enabled_state: true).policy_names.each do |policy|
        condition = google_project_alert_policy_condition(policy: policy, filter: filter)
        describe "[#{gcp_project_id}] Audit configuration changes alert policy" do
          subject { condition }
          it { should exist }
        end
      end
    end
  end
end
