
#Create Subnets

resource "aws_subnet" "EKS1" {
  vpc_id                  = "vpc-11111111111"
  cidr_block              = "10.0.8.0/22"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1a"
  tags = {
    Name                                   = "EKS1"
    "kubernetes.io/role/elb"               = "1"
    "kubernetes.io/cluster/EKSProd" = "shared"
  }

}

resource "aws_subnet" "EKS2" {
  vpc_id                  = "vpc-111111111111"
  cidr_block              = "10.0.16.0/22"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1b"
  tags = {
    Name                                   = "EKS2"
    "kubernetes.io/role/elb"               = "1"
    "kubernetes.io/cluster/EKSProd" = "shared"
  }

}


resource "aws_subnet" "EKS3" {
  vpc_id                  = "vpc-1111111111"
  cidr_block              = "10.0.24.0/22"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1c"
  tags = {
    Name                                   = "EKS3"
    "kubernetes.io/role/internal-elb"      = "1"
    "kubernetes.io/cluster/Prod" = "shared"

  }

}

resource "aws_eip" "nat1" {
  vpc = true
  tags = {
    Name = "EKSNAT"
  }
}

resource "aws_eip" "nat2" {
  vpc = true
  tags = {
    Name = "EKSNAT"
  }
}

resource "aws_eip" "nat3" {
  vpc = true
  tags = {
    Name = "EKSNAT"
  }
}

resource "aws_nat_gateway" "EKSNAT1" {
  allocation_id = "${aws_eip.nat1.id}"
  subnet_id     = "subnet-766hf7673jf"

  tags = {
    Name = "EKSNAT1"
  }
}

resource "aws_nat_gateway" "EKSNAT2" {
  allocation_id = "${aws_eip.nat2.id}"
  subnet_id     = "subnet-435jjnj43324"

  tags = {
    Name = "EKSNAT2"
  }
}

resource "aws_nat_gateway" "EKSNAT3" {
  allocation_id = "${aws_eip.nat3.id}"
  subnet_id     = "subnet-i332ofkf333k"

  tags = {
    Name = "EKSNAT3"
  }
}

# defining the private route table

resource "aws_route_table" "EKSRoute1" {
  vpc_id = "vpc-111111111111"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.EKSNAT1.id}"
  }
  tags = {
    Name = "EKSRoute1"
  }
}


resource "aws_route_table" "EKSRoute2" {
  vpc_id = "vpc-343kml3mlml5l345"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.EKSNAT2.id}"
  }
  tags = {
    Name = "EKSRoute2"
  }
}

resource "aws_route_table" "EKSRoute3" {
  vpc_id = "vpc-111111111111"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.EKSNAT3.id}"
  }

  tags = {
    Name = "EKSRoute3"
  }
}
# associating subnets ( Private-1,2,3 for both a and b and c availability zones) to the private route tables

resource "aws_route_table_association" "EKSRouteassociate1" {
  subnet_id      = "${aws_subnet.EKS1.id}"
  route_table_id = "${aws_route_table.EKSRoute1.id}"
}

resource "aws_route_table_association" "EKSRouteassociate2" {
  subnet_id      = "${aws_subnet.EKS2.id}"
  route_table_id = "${aws_route_table.EKSRoute2.id}"
}
resource "aws_route_table_association" "EKSRouteassociate3" {
  subnet_id      = "${aws_subnet.EKS3.id}"
  route_table_id = "${aws_route_table.EKSRoute3.id}"
}


resource "aws_instance" "EKSToken" {
  ami                         = "ami-32kmabdlwlp133"
  instance_type               = "t2.small"
  associate_public_ip_address = "true"
  subnet_id                   = "subnet-232kjjk3k424lk3l"
  key_name                    = "bastion-EKS"

  tags = {

    Name = "EKSToken"
  }
}

resource "aws_security_group" "EKSTokenSG" {
  name        = "EKSTokenSG"
  description = "allow ssh"
  vpc_id      = "vpc-111111111111111"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.0.170.130/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
