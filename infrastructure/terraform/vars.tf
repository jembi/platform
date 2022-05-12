variable "AWS_REGION" {
  default = "af-south-1"
  description = "region to create the resources in"
}

variable "INSTANCE_TYPE" {
  default = "t3.small"
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

variable "AMI"{
  type = map

  default = {
    af-south-1 = "ami-0b62e6078dbaee70a"
  }
}

variable "DETAILED_MONITORING_ENABLED" {
  default = false
}

variable "DOMAIN_NAME_CREATION_ENABLED" {
  default = false
}

variable "DOMAIN_NAME" {
  default = "jembi-mercury.org"
}

variable "SUBDOMAIN_NAMES" {
  default = ""
}

########## USER VALUES ###########

variable "PUBLIC_KEY_PATH" {
  default = "/home/{user}/.ssh/{key}.pub"
  description = "This is the path to the ssh key that will be used in communincating with the aws servers created"
}

variable "PROJECT_NAME" {
  default = "jembi_mercury_dev_{user}"
}

variable "JEMBI_ACCOUNT" {
  default     = "default"
  description = "the account to use as in ~/.aws/credentials file - referenced in providers.tf"
}
