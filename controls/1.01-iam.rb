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

title 'Ensure that corporate login credentials are used'

gcp_project_id = input('gcp_project_id')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '1.1'
control_abbrev = 'iam'

# Initialize the IAMBindingsCache outside the control for efficiency
# This resource likely holds the IAM bindings for the project.
iam_bindings_cache = IAMBindingsCache(project: gcp_project_id)

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'high'

  title "[#{control_abbrev.upcase}] Ensure that corporate login credentials are used"

  desc 'Use corporate login credentials instead of personal accounts, such as Gmail accounts.'
  desc 'rationale', "It is recommended fully-managed corporate Google accounts be used for increased visibility, auditing, and controlling access to Cloud Platform resources. Email accounts based outside of the user's organization, such as personal accounts, should not be used for business purposes."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['AC-2']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations#use_corporate_login_credentials'

  org_domain = nil
  project_parent = google_project(project: gcp_project_id).parent

  if project_parent.nil?
    # This project is likely a standalone project with no organization parent.
    # In this scenario, checking corporate login credentials might not be applicable
    # or you might need a different way to define the 'corporate domain'.
    # For now, we'll skip if no parent is found.
    describe "Project #{gcp_project_id} has no organization or folder parent." do
      skip 'Cannot determine corporate domain. Skipping check for corporate login credentials.'
    end
  else
    case project_parent.type
    when 'organization'
      org_id = project_parent.id
      org_resource = google_organization(name: "organizations/#{org_id}")
      if org_resource.exists?
        org_domain = org_resource.display_name
      else
        # Fallback if organization resource doesn't exist or is inaccessible
        describe "Could not retrieve organization details for ID: #{org_id}." do
          skip 'Cannot determine corporate domain. Skipping check for corporate login credentials.'
        end
      end
    when 'folder'
      current_folder_id = project_parent.id
      found_organization = false
      # Loop upwards until an organization is found or we run out of parents
      while current_folder_id
        folder_resource = google_resourcemanager_folder(name: "folders/#{current_folder_id}")

        if folder_resource.exists? # rubocop:disable Metrics/BlockNesting
          parent_name = folder_resource.parent # This will be like "folders/123" or "organizations/456"

          if parent_name.include?('organizations/')
            org_id = parent_name.sub('organizations/', '')
            org_resource = google_organization(name: "organizations/#{org_id}")
            if org_resource.exists?
              org_domain = org_resource.display_name
              found_organization = true
              break # Exit loop once organization is found
            else
              # Organization parent exists but cannot be retrieved
              describe "Could not retrieve organization details for ID: #{org_id} (parent of folder #{current_folder_id})." do
                skip 'Cannot determine corporate domain. Skipping check for corporate login credentials.'
              end
              break # Exit loop as we hit an issue
            end
          elsif parent_name.include?('folders/')
            current_folder_id = parent_name.sub('folders/', '') # Move up to the next folder
          else
            # Unexpected parent type for a folder
            describe "Unexpected parent type '#{parent_name}' for folder #{current_folder_id}." do
              skip 'Cannot determine corporate domain. Skipping check for corporate login credentials.'
            end
            break # Exit loop
          end
        else
          # Folder resource itself doesn't exist or is inaccessible
          describe "Folder resource 'folders/#{current_folder_id}' not found or inaccessible." do
            skip 'Cannot determine corporate domain. Skipping check for corporate login credentials.'
          end
          break # Exit loop
        end
      end

      unless found_organization
        describe "Could not find an organization parent for project #{gcp_project_id} through its folder hierarchy." do
          skip 'Cannot determine corporate domain. Skipping check for corporate login credentials.'
        end
      end
    else
      # Handle other potential parent types (e.g., `None` for standalone projects, or future types)
      describe "Project #{gcp_project_id} has an unsupported parent type: #{project_parent.type}." do
        skip 'Cannot determine corporate domain. Skipping check for corporate login credentials.'
      end
    end
  end

  # Proceed with IAM checks only if org_domain was successfully determined
  if org_domain.nil?
    describe 'Corporate domain could not be determined.' do
      skip 'Skipping IAM member checks as corporate domain is unknown.'
    end
  else
    iam_bindings_cache.iam_binding_roles.each do |role|
      iam_bindings_cache.iam_bindings[role].members.each do |member|
        # Skip service accounts
        next if member.to_s.end_with?('.gserviceaccount.com')
        # Skip allUsers and allAuthenticatedUsers
        next if %w[allUsers allAuthenticatedUsers].include?(member.to_s)

        describe "[#{gcp_project_id}] [Role:#{role}] Its member #{member}" do
          subject { member.to_s }
          # Using `should not match` for personal accounts implies any non-corporate domain
          # If the intent is strictly to allow ONLY corporate domains, then `should match`
          # but usually the goal is to exclude personal ones.
          it { should match(/@#{Regexp.escape(org_domain)}/) } # Use Regexp.escape for safety
        end
      end
    end
  end
end
