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

title 'Ensure log metric filter and alerts exists for Project Ownership assignments/changes'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "2.4"
control_abbrev = "logging"

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure log metric filter and alerts exists for Project Ownership assignments/changes"

  desc "In order to prevent unnecessarily project ownership assignments to users/serviceaccounts and further misuses of project and resources, all roles/Owner assignments should be monitored.

Members (users/Service-Accounts) with role assignment to primitive role roles/owner are Project Owners.

Project Owner has all the privileges on a project it belongs to. These can be summarized as below:

- All viewer permissions on All GCP Services part within the project
- Permissions for actions that modify state of All GCP Services within the
project
- Manage roles and permissions for a project and all resources within the
project
- Set up billing for a project

Granting owner role to a member (user/Service-Account) will allow members to modify the IAM policy. Therefore grant the owner role only if the member has a legitimate purpose to manage the IAM policy. This is because as project IAM policy contains sensitive access control data and having a minimal set of users manage it will simplify any auditing that you may have to do."
  desc "rationale", "Project Ownership Having highest level of privileges on a project, to avoid misuse of project resources project ownership assignment/change actions mentioned should be monitored and alerted to concerned recipients.

- Sending project ownership Invites
- Acceptance/Rejection of project ownership invite by user
- Adding `role\owner` to a user/service-account
- Removing a user/Service account from `role\owner`"

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

  log_filter = "(protoPayload.serviceName=\"cloudresourcemanager.googleapis.com\") AND (ProjectOwnership OR projectOwnerInvitee) OR (protoPayload.serviceData.policyDelta.bindingDeltas.action=\"REMOVE\" AND protoPayload.serviceData.policyDelta.bindingDeltas.role=\"roles/owner\") OR (protoPayload.serviceData.policyDelta.bindingDeltas.action=\"ADD\" AND protoPayload.serviceData.policyDelta.bindingDeltas.role=\"roles/owner\")"
  describe "[#{gcp_project_id}] Project Ownership changes filter" do
    subject { google_project_metrics(project: gcp_project_id).where(metric_filter: log_filter) }
    it { should exist }
  end

  google_project_metrics(project: gcp_project_id).where(metric_filter: log_filter).metric_types.each do |metrictype|
    describe.one do
      filter = "metric.type=\"#{metrictype}\" resource.type=\"audited_resource\""
      google_project_alert_policies(project: gcp_project_id).where(policy_enabled_state: true).policy_names.each do |policy|
        condition = google_project_alert_policy_condition(policy: policy, filter: filter)
        describe "[#{gcp_project_id}] Project Ownership changes alert policy" do
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
