# Introduction to Running InSpec in Cloud Shell


## Let's get started!

This guide will show you how to install InSpec on your Cloud Shell instance and how to use InSpec to check the infrastructure in your Google Cloud Project against the CIS GCP Benchmark.

**Time to complete**: About 5 minutes

Click the **Start** button to move to the next step.


## What is InSpec?

Before we jump in, let's briefly go over what InSpec can do.

[InSpec](https://github.com/inspec/inspec), a popular framework in the DevSecOps community, checks the configuration state of resources within virtual machines, containers, and cloud providers such as GCP, AWS, and Azure. InSpec's lightweight nature, approachable domain specific Language (DSL) and extensibility, make it a valuable tool for:
- Expressing compliance policies as code
- Enabling development teams to add application-specific tests and assess the compliance of their applications to security policies before pushing changes to the production environment.
- Automating compliance verification in CI/CD pipelines and as part of the release process
- Unifying compliance assessments across multiple cloud providers and on premises environments

Continue on to the next step to start setting up your tutorial.


## Install InSpec

InSpec is distributed as a Ruby gem and your Cloud Shell instance has a Ruby environment already configured. All you need to do is install the InSpec gem:

```bash
gem install inspec-bin -v 4.18.51 --no-document
```

**Tip**: Click the Copy to Cloud Shell button on the side of the code box and then hit Enter in your terminal. You can also click the copy button on the side of the code box and paste the command in the Cloud Shell terminal to run it.

Next, you’ll select a Google Cloud Project to scan with InSpec.

## Select a Google Cloud Project to scan

Pick a project where you have sufficient permissions. We'll use your user credentials in Cloud Shell to scan the project.

<walkthrough-project-setup></walkthrough-project-setup>

The project you selected is **{{project-id}}**. If this is blank, make sure you selected a project using the dropdown box above.

Hit Next after you successfully selected your project.


## Scan Your Project

To scan your project against the CIS GCP Benchmark with InSpec, run:

```bash
CHEF_LICENSE=accept-no-persist ~/.gems/bin/inspec exec https://github.com/GoogleCloudPlatform/inspec-gcp-cis-benchmark.git -t gcp:// --input gcp_project_id={{project-id}}
```

This should take about two minutes to complete.

Once complete, your terminal output should look something like this:

```
Profile Summary: 14 successful controls, 34 control failures, 7 controls skipped
Test Summary: 107 successful, 88 failures, 7 skipped
```

You can scroll up to see the details of passing and failing tests.

To scan another project, press the Previous button and select a different project.

Press Next if you're done scanning projects.

## Congratulations

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>

You’re all set!

You can now scan your Google Cloud Projects with InSpec directly from Cloud Shell.