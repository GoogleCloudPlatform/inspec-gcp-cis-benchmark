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

title ' Ensure that instances are not configured to use the default service account '

gcp_project_id = input('gcp_project_id')
gce_zones = input('gce_zones')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '4.1'
control_abbrev = 'vms'

gce_instances = GCECache(project: gcp_project_id, gce_zones: gce_zones).gce_instances_cache

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'medium'

  title "[#{control_abbrev.upcase}] Ensure that instances are not configured to use the default compute engine service account with full access to all Cloud APIs"

  desc 'To support principle of least privileges and prevent potential privilege escalation it is recommended that instances are not assigned to default service account Compute Engine default service account'
  desc 'rationale', 'The default Compute Engine service account has the Editor role on the project, which allows read and write access to most Google Cloud Services. To defend against privilege escalations if your VM is compromised and prevent an attacker from gaining access to all of your project, it is recommended to not use the default Compute Engine service account. Instead, you should create a new service account and assigning only the permissions needed by your instance.'

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances'
  ref 'GCP Docs', url: 'https://cloud.google.com/compute/docs/access/service-accounts'

  project_number = google_project(project: gcp_project_id).project_number
  gce_instances.each do |instance|
    next if instance[:name] =~ /^gke-/
    google_compute_instance(project: gcp_project_id, zone: instance[:zone], name: instance[:name]).service_accounts.each do |serviceaccount|
      describe "VM #{instance[:name]} should not include the default compute engine service account" do
        subject { serviceaccount.email }
        it { should_not include("#{project_number}-compute@developer.gserviceaccount.com") }
      end
    end
  end
end
