terraform {
  backend "s3" {
    bucket         = "redsift-labs-terraform-states"
    dynamodb_table = "terraform-locks"
    region         = "eu-west-2"
    key            = "ingraind-test-infra"
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "ingraind" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Environment = "ingraind-test"
    yor_trace   = "bc815855-9a3d-427f-abb7-4350a6b9902e"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.ingraind.id}"

  tags = {
    Environment = "ingraind-test"
    yor_trace   = "1cd77b56-9662-4402-8d07-3f64fc01d836"
  }
}

resource "aws_subnet" "ingraind" {
  vpc_id                  = "${aws_vpc.ingraind.id}"
  cidr_block              = "172.16.10.0/24"
  map_public_ip_on_launch = true

  availability_zone = "eu-west-1c"
  tags = {
    Environment = "ingraind-test"
    yor_trace   = "41db32a7-fcbe-44f6-96fa-a08702829ca7"
  }
}

resource "aws_route_table" "internet" {
  vpc_id = "${aws_vpc.ingraind.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Environment = "ingraind-test"
    yor_trace   = "5121eea0-592b-49b5-b30b-dc2e5ac36278"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.ingraind.id}"
  route_table_id = "${aws_route_table.internet.id}"
}

resource "aws_security_group" "allow_ssh" {
  vpc_id = "${aws_vpc.ingraind.id}"

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = "ingraind-test"
    yor_trace   = "d24f9af8-ddf1-40bd-973a-749cdd7e3b08"
  }
}
