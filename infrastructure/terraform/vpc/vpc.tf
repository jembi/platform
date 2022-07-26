resource "aws_vpc" "vpc" {
  cidr_block = "10.1.0.0/16"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
  instance_tenancy = "default"

  tags = {
    Name = "${var.VPC_NAME}-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  cidr_block = "10.1.10.0/24"
  vpc_id = "${aws_vpc.vpc.id}"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.VPC_NAME}-public-subnet"
  }
}

output "VPC_ID" {
  value = "${aws_vpc.vpc.id}"
}

output "SUBNET_ID" {
  value = "${aws_subnet.public_subnet.id}"
}
