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
#export GOOGLE_APPLICATION_CREDENTIALS="/Users/aayu/dev/inspec-gcp-cis-benchmark/inspec-key.json"

title 'Ensure that BigQuery datasets are not anonymously or publicly accessible'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "7.1"
control_abbrev = "storage"

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure that BigQuery datasets are not anonymously or publicly accessible"

  desc "It is recommended that the IAM policy on BigQuery datasets does not allow anonymous
and/or public access."
  desc "rationale", "Granting permissions to allUsers or allAuthenticatedUsers allows anyone to access the
dataset. Such access might not be desirable if sensitive data is being stored in the dataset.
Therefore, ensure that anonymous and/or public access to a dataset is not allowed."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/storage/docs/access-control/iam-reference"
  ref "GCP Docs", url: "https://cloud.google.com/storage/docs/access-control/making-data-public"


  google_bigquery_datasets(project: gcp_project_id).ids.each do |name|
    google_bigquery_dataset(project: gcp_project_id, name: name.split(':').last).access.each do |access|
      describe"[#{gcp_project_id}] BigQuery Dataset #{name} should not be anonymously or publicly accessible," do
        subject { access }
        its('iam_member') { should_not cmp 'allUsers' }
        its('special_group') { should_not cmp 'allAuthenticatedUsers' }
      end
    end
  end
end


