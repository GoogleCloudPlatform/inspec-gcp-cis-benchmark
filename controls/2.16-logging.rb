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

title 'Ensure Logging is enabled for HTTP(S) Load Balancer'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '2.16'
control_abbrev = 'logging'

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'medium'

  title "[#{control_abbrev.upcase}] Ensure Logging is enabled for HTTP(S) Load Balancer"

  desc 'Logging enabled on a HTTPS Load Balancer will show all network traffic and its destination.'
  desc 'rationale', 'Logging will allow you to view HTTPS network traffic to your web applications. On high use systems with a high percentage sample rate, the logging file may grow to high capacity in a short amount of time. Ensure that the sample rate is set appropriately so that storage costs are not exorbitant.'

  tag cis_scored: true
  tag cis_level: 2
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: %w[] # Add relevant NIST controls if any in future

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/load-balancing/'
  ref 'GCP Docs', url: 'https://cloud.google.com/load-balancing/docs/https/https-logging-monitoring#gcloud:-global-mode'
  ref 'GCP Docs', url: 'https://cloud.google.com/sdk/gcloud/reference/compute/backend-services/'

  # Check Global Backend Services
  google_compute_backend_services(project: gcp_project_id).where(protocol: /HTTPS?/).backend_service_names.each do |backend_service_name|
    describe "[#{control_abbrev.upcase}] #{control_id} - Global Backend Service: #{backend_service_name}" do
      subject { google_compute_backend_service(project: gcp_project_id, name: backend_service_name) }
      it { should have_logging_enabled }
      # its('log_config.sample_rate') { should cmp > 0 } # Optional: Check if sample rate is also configured if needed
    end
  end

  # Check Regional Backend Services
  google_compute_regions(project: gcp_project_id).region_names.each do |region_name|
    google_compute_region_backend_services(project: gcp_project_id, region: region_name).where(protocol: /HTTPS?/).backend_service_names.each do |backend_service_name|
      describe "[#{control_abbrev.upcase}] #{control_id} - Regional Backend Service: #{backend_service_name} in #{region_name}" do
        subject { google_compute_region_backend_service(project: gcp_project_id, region: region_name, name: backend_service_name) }
        it { should have_logging_enabled }
        # its('log_config.sample_rate') { should cmp > 0 } # Optional
      end
    end
  end

  # If no backend services are found, this control could be considered not applicable or pass by default.
  # Adding a check to ensure the test runs if backend services exist.
  combined_backend_services = google_compute_backend_services(project: gcp_project_id).where(protocol: /HTTPS?/).backend_service_names +
                              google_compute_regions(project: gcp_project_id).region_names.flat_map do |region_name|
                                google_compute_region_backend_services(project: gcp_project_id, region: region_name).where(protocol: /HTTPS?/).backend_service_names
                              end

  if combined_backend_services.empty?
    describe "[#{control_abbrev.upcase}] #{control_id} - No HTTP(S) Backend Services Found" do
      skip 'No HTTP(S) backend services found in the project, this control is Not Applicable.'
    end
  end
end
