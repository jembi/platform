variable "AWS_REGION" {
  default     = "af-south-1"
  description = "region to create the resources in"
}

variable "INSTANCE_TYPE" {
  default = "t3.xlarge"
}

variable "INSTANCE_COUNT" {
  default = "3"
}

variable "ALARMS_ENABLED" {
  default = true
}

variable "VOLUME_SIZE" {
  default = 32
}

variable "AMI" {
  type = map(any)

  default = {
    af-south-1 = "ami-0ecd7c3947c3e5de8"
  }
}

variable "DETAILED_MONITORING_ENABLED" {
  default = false
}

variable "DOMAIN_NAME_CREATION_ENABLED" {
  default = true
}

variable "NODE_DOMAIN_NAME_CREATION_ENABLED" {
  default = true
}

variable "SUB_DOMAIN_NAME_CREATION_ENABLED" {
  default = true
}

########## USER VALUES ###########

variable "DOMAIN_NAME" {
  default = "{user}.jembi.cloud"
}

variable "HOSTED_ZONE_ID" {
  default = ""
  description = "Set this to the hosted zone ID for the domain name you want to use"
}

variable "VPC_ID" {
  default = ""
  description = "Set this to the VPC ID you want to use, VPCs are limited to try to use one that exists for this AWS account"
}

variable "SUBNET_ID" {
  default = ""
  description = "Set this to the subnet ID you want to use, a subnet will be created along with a VPC"
}

variable "PUBLIC_KEY_PATH" {
  default     = "/home/{user}/.ssh/{key}.pub"
  description = "This is the path to the ssh key that will be used in communincating with the aws servers created"
}

variable "PROJECT_NAME" {
  default = "jembi_platform_dev_{user}"
}

variable "ACCOUNT" {
  default     = "default"
  description = "the account to use as in ~/.aws/credentials file - referenced in providers.tf"
}
