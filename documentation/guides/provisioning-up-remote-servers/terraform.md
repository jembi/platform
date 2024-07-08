---
description: A tool that enables infrastructure as code to set up servers in AWS EC2.
---

# Terraform

## Cloud Dev environments

To set up a developer's development environment in AWS, run this terraform project. The scripts will allow the joining of an existing VPC, the creation of a public subnet and a variable number of EC2 instances that the user will have SSH access to. Alarms have been created in the scripts which will auto-shutdown the instances after a configurable period, based on CPU metrics. A Lambda scheduled event can also be configured which can run at a regular interval to shut down any instances that may still be running.

Pre-requisites

* [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Creating a VPC

This should only be done once per AWS account as there is a limit of 5 per region. Please check if this has already been run and use the existing `VPC_ID` and `SUBNET_ID` for the following section if it does and skips to the next section.

Navigate to the `infrastructure/terraform/vpc` directory

Initialize Terraform project:

```
terraform init
```

Execute the following:

```
terraform apply
```

Copy the output for the next step, e.g for ICAP this has already been run and this is the result:

```
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

SUBNET_ID = "subnet-0004b0dacb5862d59"
VPC_ID = "vpc-067ab69f374ac9f47"
```

### Creating EC2 instances

Navigate to the `infrastructure/terraform` directory

Initialize Terraform project:

```
terraform init
```

The following properties have to be set:

```
PUBLIC_KEY_PATH - path to the user's public key file that gets injected into the servers created
PROJECT_NAME    - unique project name that is used to identify each VPC and its resources
HOSTED_ZONE_ID  - (only if you are creating domains, which by default you are) the hosted zone to use, this must be created in the AWS console
DOMAIN_NAME     - the base domain name to use
SUBNET_ID       - the subnet id to use, copy this from the previous step
VPC_ID          - the subnet id to use, copy this from the previous step
```

The configuration can be done using an terraform variable file. Create a file called `my.tfvars`. Below is an example that illustrates the structure of the environment variables file. This example is of a configuration that you can use for the ICAP CDR. Please replace `{user}` with your own user.

```
PUBLIC_KEY_PATH = "/home/{user}/.ssh/id_rsa.pub"
PROJECT_NAME = "jembi_platform_dev_{user}"
HOSTED_ZONE_ID = "Z00782582NSP6D0VHBCMI"
DOMAIN_NAME = "{user}.jembi.cloud"
SUBNET_ID = "subnet-0004b0dacb5862d59"
VPC_ID = "vpc-067ab69f374ac9f47"
```

The AWS account to be used is defined in the `~/.aws/credentials` file. If you don't have file this make sure you have configured the AWS CLI.

```
cat ~/.aws/credentials
```

```
[default]
aws_access_key_id = AKIA6FOPGN5TYHXXXXX
aws_secret_access_key = Qf7E+qcXXXXXXQh4XznN4MM8qR/VP/SXgXXXXX
[jembi-sandbox]
aws_access_key_id = AKIASOHFAV527JCXXXXX
aws_secret_access_key = YXFu3XxXXXXXTeNXdUtIg0gb9Ro7gJ89XXXXX
[jembi-icap]
aws_access_key_id = AKIAVFN7GJJFS6LXXXXX
aws_secret_access_key = b2I6jhwXXXXX4YehBCx/7rKl1JZjYdbtXXXXX
```

The sample file above has access to 3 accounts and the options for `<account_name>` could be "default", "jembi-sandbox", "jembi-icap"

Optionally, add `ACCOUNT = "<account_name>"` to `my.tfvars` if you want to use something other than `default`.

The flag for specifying an environment variables file is `-var-file`, create the AWS stack by running:

```
terraform apply -var-file my.tfvars
```

Once the script has run successfully, the ip addresses and domains for the servers will be displayed:

```
Apply complete! Resources: 13 added, 0 changed, 0 destroyed.

Outputs:

domains = {
  "domain_name" = "{user}.jembi.cloud"
  "node_domain_names" = [
    "node-0.{user}.jembi.cloud",
    "node-1.{user}.jembi.cloud",
    "node-2.{user}.jembi.cloud",
  ]
  "subdomain" = [
    "*.{user}.jembi.cloud",
  ]
}
public_ips = [
  "13.245.143.121",
  "13.246.39.101",
  "13.246.39.92",
]
```

SSH access should be now available - use the default 'ubuntu' user - `ssh ubuntu@<ip_address>`

Destroying the AWS stack - run:

```
terraform destroy -var-file my.tfvars
```
