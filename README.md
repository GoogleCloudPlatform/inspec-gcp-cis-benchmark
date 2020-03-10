# GCP CIS 1.0 Benchmark Inspec Profile

This repository holds the [Google Cloud Platform (GCP)](https://cloud.google.com/) [Center for Internet Security (CIS)](https://www.cisecurity.org) [version 1.0 Benchmark](https://www.cisecurity.org/benchmark/google_cloud_computing_platform/) [Inspec](https://www.inspec.io/) Profile.

## Required Disclaimer

This is not an officially supported Google product. This code is intended to help users assess their security posture on the Google Cloud against the CIS Benchmark. This code is not certified by CIS.

## Coverage

The following GCP CIS v1.0 Benchmark Controls are not covered:

* Identity and Access Management 1.2 - "Ensure that multi-factor authentication is enabled for all non-service accounts"
* Identity and Access Management 1.10 - "Ensure API keys are not created for a project"
* Identity and Access Management 1.11 - "Ensure API keys are restricted to use by only specified Hosts and Apps"
* Identity and Access Management 1.12 - "Ensure API keys are restricted to only APIs that application needs access"
* Identity and Access Management 1.13 - "Ensure API keys are rotated every 90 days"
* Cloud SQL Database Services 6.3 - "Ensure that MySql database instance does not allow anyone to connect with administrative privileges"
* Cloud SQL Database Services 6.4 - "Ensure that MySQL Database Instance does not allows root login from any Host"

## Usage

### Profile Attributes

* **gcp_project_id** - (Default: "", type: string) - The target GCP Project that must be specified.
* **sa_key_older_than_seconds** - (Default: 7776000, type: int, CIS IAM 1.6) - The maximum allowed age of GCP User-managed Service Account Keys (90 days in seconds).
* **kms_rotation_period_seconds** - (Default: 31536000, type: int, CIS IAM 1.8) - The maximum allowed age of KMS keys (1 year in seconds).


### Cloud Shell Walkthrough

Use this Cloud Shell walkthrough for a hands-on example.

[![Open this project in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.png)](https://console.cloud.google.com/cloudshell/open?git_repo=https://github.com/GoogleCloudPlatform/inspec-gcp-cis-benchmark&page=editor&tutorial=walkthrough.md)

### CLI Example

```
$ git clone https://github.com/googlecloudplatform/inspec-gcp-cis-benchmark
$ cd inspec-gcp-cis-benchmark
$ cat attrs.yml 
gcp_project_id: <your-project-id>
sa_key_older_than_seconds: 7776000
kms_rotation_period_seconds: 31536000
```

```
$ inspec exec . -t gcp:// --attrs attrs.yml
...snip...
Profile Summary: 48 successful controls, 5 control failures, 7 controls skipped
Test Summary: 166 successful, 7 failures, 7 skipped
```
