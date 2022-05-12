resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name = "${var.PROJECT_NAME}-igw"
  }
}

resource "aws_route_table" "public_crt" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "${var.PROJECT_NAME}-public-crt"
  }
}

resource "aws_route_table_association" "crta_public_subnet" {
  subnet_id = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route_table.public_crt.id}"
}

resource "aws_security_group" "ssh_allowed" {
  vpc_id = "${aws_vpc.vpc.id}"
  name = "${var.PROJECT_NAME}_sg"
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 2376
    to_port = 2377
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 7946
    to_port = 7946
    protocol = "udp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 7946
    to_port = 7946
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 4789
    to_port = 4789
    protocol = "udp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags = {
    Name = "${var.PROJECT_NAME}-ssh-allowed"
  }
}
