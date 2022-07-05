# Cloud Dev environments

To setup a developers development environment in AWS, run this terraform project. The scripts will create a VPC, public
subnet and a variable number of EC2 instances that the user will have ssh access.
An alarm has been created in the scripts that will auto-shutdown the instances after a configurable period, based on
cpu metrics.
A scheduled event is also configured which can run at a regular interval to shutdown any instances that may be
still be running

Pre-requisites

- [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

---

Initialize Terraform project:

```sh
terraform init
```

The following properties have to be set:

```tf
PUBLIC_KEY_PATH - path to the user's public key file that gets injected into the servers created
PROJECT_NAME    - unique project name that is used to identify each VPC and its resources
```

The configuration can be done in the `vars.tf` file or by using environment variables or an environment variables file. The file has to have the extension `.tfvars`.
Below is an example that illustrates the structure of the environment variables file

```tf
PUBLIC_KEY_PATH = "/home/{user}/.ssh/{key}.pub"
PROJECT_NAME = "jembi_mercury_dev_{user}"
```

The flag for specifying an environment variables file is `-var-file` and the one for specifying an enviroment variable is `TF_VAR_<variable name>`. Below are examples that illustrate how to use the flags:

```tf
TF_VAR_PROJECT_NAME=jembi_mercury_dev terraform apply

terraform apply -var-file=<path to env file>
```

The account to be used is defined in the `~/.aws/credentials` file

```sh
cat ~/.aws/credentials
```

```txt
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

The sample file above has access to 3 accounts and the options for '<_account-name_>' could be "default",
"jembi-sandbox",
"jembi-icap"

```tf
variable "JEMBI_ACCOUNT" {
  default = "<account_name>"
  description = "the account to use as in ~/.aws/credentials file - referenced in providers.tf"
}
```

Run terraform to create the AWS stack:

```sg
terraform apply -var-file="userValues.tfvars"
```

To set variable values other than default, add the `-var` flag as follows (using INSTANCE_COUNT as an example):

```sg
terraform apply -var="INSTANCE_COUNT=4"
```

Once the script has run sucessfully, the ip addresses for the servers will be displayed:

```txt
....
Apply complete! Resources: 11 added, 0 changed, 0 destroyed.

Outputs:

public_A_ip = "13.24x.xx.xx"
public_B_ip = "13.24x.xx.xx"
public_C_ip = "13.24x.xx.xx"
```

SSH access should be now available - use the default 'ubuntu' user -
`ssh ubuntu@<ip_address>`

Destroying the AWS stack - run:

```sg
terraform destroy -var-file="userValues.tfvars"
```
