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

title 'Ensure that MySQL Database Instance does not allows root login from any Host'

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "6.4"
control_abbrev = "db"

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure that MySQL Database Instance does not allows root login from any Host"

  desc "It is recommended that root access to a MySql Database Instance should be allowed only through specific white-listed trusted IPs."
  desc "rationale", "When root access is allowed for any host, any host from authorized networks can attempt to authenticate to a MySql Database Instance using administrative privileges. To minimize attack surface root access can explicitly allowed from only trusted IPs (Hosts) to support database related administrative tasks."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/MySql/docs/MySql/create-manage-users"

  describe "Not scored" do
    before do
      skip
    end
    it {should eq "Not scored"}
  end

end
