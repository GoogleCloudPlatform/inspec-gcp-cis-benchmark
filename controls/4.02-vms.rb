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

title 'Ensure that instances are not configured to use the default service account with full access to all Cloud APIs'

gcp_project_id = input('gcp_project_id')
gce_zones = input('gce_zones')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '4.2'
control_abbrev = 'vms'

gce_instances = GCECache(project: gcp_project_id, gce_zones: gce_zones).gce_instances_cache

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'medium'

  title "[#{control_abbrev.upcase}] Ensure that instances are not configured to use the default service account with full access to all Cloud APIs"

  desc 'To support principle of least privileges and prevent potential privilege escalation it is recommended that instances are not assigned to default service account Compute Engine default service account with Scope Allow full access to all Cloud APIs.'
  desc 'rationale', "Along with ability to optionally create, manage and use user managed custom service accounts, Google Compute Engine provides default service account Compute Engine default service account for an instances to access necessary cloud services. Project Editor role is assigned to Compute Engine default service account hence, This service account has almost all capabilities over all cloud services except billing. However, when Compute Engine default service account assigned to an instance it can operate in 3 scopes.

1. Allow default access: Allows only minimum access required to run an Instance (Least Privileges)
2. Allow full access to all Cloud APIs: Allow full access to all the cloud APIs/Services (Too much access)
3. Set access for each API: Allows Instance administrator to choose only those APIs that are needed to perform specific business functionality expected by instance

When an instance is configured with Compute Engine default service account with Scope Allow full access to all Cloud APIs, based on IAM roles assigned to the user(s) accessing Instance, it may allow user to perform cloud operations/API calls that user is not supposed to perform leading to successful privilege escalation."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ["AC-2", "AC-6"]

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances'
  ref 'GCP Docs', url: 'https://cloud.google.com/compute/docs/access/service-accounts'

  project_number = google_project(project: gcp_project_id).project_number
  gce_instances.each do |instance|
    next if instance[:name] =~ /^gke-/
    google_compute_instance(project: gcp_project_id, zone: instance[:zone], name: instance[:name]).service_accounts.each do |serviceaccount|
      next if serviceaccount.email != "#{project_number}-compute@developer.gserviceaccount.com"
      describe "[#{gcp_project_id}] Instance #{instance[:zone]}/#{instance[:name]}" do
        subject { serviceaccount.scopes }
        it { should_not include 'https://www.googleapis.com/auth/cloud-platform' }
      end
    end
  end
end
