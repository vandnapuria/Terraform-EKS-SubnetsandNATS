variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}

provider "aws" {
  version = ">= 2.28.1"
  region  = "us-east-1"
}

data "aws_availability_zones" "available" {}



resource "aws_eip" "nat" {
  count = 3
  vpc   = true
tags = {
    Name = "BossEKSNAT"
  }
}
module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  name                 = "BossEKSVPC"
  cidr                 = "10.4.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.4.0.0/20", "10.4.16.0/20", "10.4.32.0/20"]
  private_subnets      = ["10.4.48.0/20", "10.4.64.0/20", "10.4.80.0/20"]
  enable_nat_gateway   = true
  single_nat_gateway   = false
  reuse_nat_ips        = true
  external_nat_ip_ids  = "${aws_eip.nat.*.id}"
  enable_dns_hostnames = true
  enable_dns_support   = true



  public_subnet_tags = {

    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/BossEKSProd" = "shared"
  }

  private_subnet_tags = {

    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/BossEKSProd" = "shared"
  }
}
