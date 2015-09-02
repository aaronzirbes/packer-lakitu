/* terraform.tfvars: Example */
/*
aws_access_key_id = "your amazon access key"
aws_secret_access_key = "your amazon secret key"
*/

variable "lakitu_ami" {
    default = "ami-bb1593d0"
    description = "AWS Access Key"
}

variable "aws_region" {
    default = "us-east-1"
    description = "AWS Region"
}

variable "aws_access_key_id" {
    description = "AWS Access Key"
}

variable "aws_secret_access_key" {
    description = "AWS Secret Key"
}

# AWS Creds
provider "aws" {
    access_key = "${var.aws_access_key_id}"
    secret_key = "${var.aws_secret_access_key}"
    region = "${var.aws_region}"
}

/* Security Groups and stuff */
resource "aws_security_group" "http_8080_only" {

    name = "lakitu"
    description = "8080/tcp open to all and SSH whitelist"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["174.53.163.89/32", "75.168.148.80/32", "207.67.44.210/32", "75.168.71.92/32"]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "lakitu"
    }
}

/* IAM Role and Instance Profile */
resource "aws_iam_instance_profile" "lakitu" {
    name = "lakitu"
    roles = ["${aws_iam_role.lakitu.name}"]
}

resource "aws_iam_role" "lakitu" {
    name = "lakitu"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "lakitu-sqs" {
    name = "lakitu-iam-sqs-attachment"
    users = ["mncc", "ajz"]
    roles = ["${aws_iam_role.lakitu.name}"]
    groups = ["night-watchmen"]
    policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

/* The OEM Portal Web Frontend. */
resource "aws_instance" "lakitu" {
    /* You get the AMI from the packer output */
    ami = "${var.lakitu_ami}"
    instance_type = "t2.micro"
    key_name = "lakitu-ssh"
    iam_instance_profile = "lakitu"
    security_groups = [ "${aws_security_group.http_8080_only.name}" ]
    associate_public_ip_address = true
    tags {
        Name = "lakitu"
    }
}

/* Register the frontend's IP address */
resource "aws_route53_record" "lakitu" {
   zone_id = "Z3EAXMRXHCX6YA"
   name = "lakitu.aaronzirbes.com"
   type = "A"
   ttl = "60"

   records = ["${aws_instance.lakitu.public_ip}"]
}
