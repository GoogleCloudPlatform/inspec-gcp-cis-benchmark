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

title 'Ensure that logging is enabled for Cloud storage buckets'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
bucket_logging_ignore_regex = attribute('bucket_logging_ignore_regex')
control_id = "5.3"
control_abbrev = "storage"

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure that logging is enabled for Cloud storage buckets"

  desc "Storage Access Logging generates a log that contains access records for each request made to the Storage bucket. An access log record contains details about the request, such as the request type, the resources specified in the request worked, and the time and date the request was processed. Cloud Storage offers access logs and storage logs in the form of CSV files that can be downloaded and used for analysis/incident response. Access logs provide information for all of the requests made on a specified bucket and are created hourly, while the daily storage logs provide information about the storage consumption of that bucket for the last day. The access logs and storage logs are automatically created as new objects in a bucket that you specify. An access log record contains details about the request, such as the request type, the resources specified in the request worked, and the time and date the request was processed. While storage Logs helps to keep track the amount of data stored in the bucket. It is recommended that storage Access Logs and Storage logs are enabled for every Storage Bucket."
  desc "rationale", "By enabling access and storage logs on target Storage buckets, it is possible to capture all events which may affect objects within target buckets. Configuring logs to be placed in a separate bucket allows access to log information which can be useful in security and incident response workflows.

In most cases, Cloud Audit Logging is the recommended method for generating logs that track API operations performed in Cloud Storage:

- Cloud Audit Logging tracks access on a continuous basis.
- Cloud Audit Logging produces logs that are easier to work with.
- Cloud Audit Logging can monitor many of your Google Cloud Platform services, not just Cloud Storage.

In some cases, you may want to use access & storage logs instead.

You most likely want to use access logs if:

- You want to track access for public objects.
- You use Access Control Lists (ACLs) to control access to your objects.
- You want to track changes made by the Object Lifecycle Management feature.
- You want your logs to include latency information, or the request and response size of individual HTTP requests.

You most likely want to use storage logs if:

- You want to track the amount of data stored in your buckets."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/storage/docs/access-logs"

  google_storage_buckets(project: gcp_project_id).bucket_names.each do |bucket|
    next if bucket =~ /#{bucket_logging_ignore_regex}/
    describe "[#{gcp_project_id}] GCS Bucket #{bucket}" do
      subject { google_storage_bucket(name: bucket) }
      it { should have_logging_enabled }
    end
  end

end
