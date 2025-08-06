resource "aws_vpc" "gozie_project_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "gozie_tf_vpc"
    Environment = "Dev"
  }
}

# Internet Gateway for the VPC
resource "aws_internet_gateway" "gozie_project_igw" {
  vpc_id = aws_vpc.gozie_project_vpc.id

  tags = {
    Name        = "gozie_project_igw_tag"
    Environment = "Dev"
  }
}

# Public Subnet for the VPC
# This subnet is used for resources that need to be accessible from the internet.
# It is associated with the Internet Gateway for outbound internet access.
resource "aws_subnet" "public_subnet_gozie_project" {
  vpc_id                  = aws_vpc.gozie_project_vpc.id
  cidr_block              = "10.0.0.0/19"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name        = "public_subnet_gozie_project"
    Environment = "Dev"
  }
}

# Route Table for the Public Subnet
# This route table is associated with the public subnet and routes traffic to the Internet Gateway.
# It allows resources in the public subnet to access the internet.
resource "aws_route_table" "public_rt_gozie_tf" {
  vpc_id = aws_vpc.gozie_project_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gozie_project_igw.id
  }

  tags = {
    Name        = "public_subnet_route-table_gozie_project"
    Environment = "Dev"
  }
}

resource "aws_route_table_association" "public_sub_gozie_tf" {
  subnet_id      = aws_subnet.public_subnet_gozie_project.id
  route_table_id = aws_route_table.public_rt_gozie_tf.id
}




# Public Subnet for the VPC
# This subnet is used for resources that need to be accessible from the internet.
# It is associated with the Internet Gateway for outbound internet access.
resource "aws_subnet" "public_subnet_gozie_project2" {
  vpc_id                  = aws_vpc.gozie_project_vpc.id
  cidr_block              = "10.0.32.0/19"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    "Name" = "public_subnet_gozie_project2"

  }
}

# Route Table for the Public Subnet
# This route table is associated with the public subnet and routes traffic to the Internet Gateway.
# It allows resources in the public subnet to access the internet.
resource "aws_route_table" "public_rt_gozie_tf2" {
  vpc_id = aws_vpc.gozie_project_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gozie_project_igw.id
  }

  tags = {
    Name = "public_subnet_route-table_gozie_project2"
  }
}

resource "aws_route_table_association" "public_sub_gozie_tf2" {
  subnet_id      = aws_subnet.public_subnet_gozie_project2.id
  route_table_id = aws_route_table.public_rt_gozie_tf2.id
}







# Elastic IP for the NAT Gateway
# This Elastic IP is used by the NAT Gateway to provide internet access to resources in private subnets.
# It is associated with the VPC to ensure proper routing.

/*
resource "aws_eip" "nat_gozie_tf" {
  domain = "vpc"

  tags = {
    Name = "nat_gozie_tf_tag"
  }
}

# NAT Gateway for the VPC
# The NAT Gateway allows instances in private subnets to initiate outbound traffic to the internet

resource "aws_nat_gateway" "nat_gozie_tf" {
  allocation_id = aws_eip.nat_gozie_tf.id
  subnet_id     = aws_subnet.public_subnet_gozie_project.id

  tags = {
    Name = "nat_gozie_tf_tag"
  }

  depends_on = [aws_internet_gateway.gozie_project_igw]
}


# Private Subnet for the VPC
# This subnet is used for resources that do not need direct access to the internet.
# It routes outbound traffic through the NAT Gateway for internet access.
resource "aws_subnet" "private_subnet_gozie_project" {
  vpc_id            = aws_vpc.gozie_project_vpc.id
  cidr_block        = "10.0.64.0/19"
  
  tags = {
    "Name" = "private_sub_gozie_rt"
    
  }
}



# Route Table for the Private Subnet
# This route table is associated with the private subnet and routes outbound traffic through the NAT Gateway.
# It allows resources in the private subnet to access the internet indirectly.
resource "aws_route_table" "private_rt_gozie_tf" {
  vpc_id = aws_vpc.gozie_project_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gozie_tf.id
  }

  tags = {
    Name = "private_sub_gozie_rt"
  }
}

# Route Table Association for the Private Subnet
# This associates the private subnet with the private route table, enabling routing for resources in the private
resource "aws_route_table_association" "private_sub_gozie_tf" {
  subnet_id      = aws_subnet.private_subnet_gozie_project.id
  route_table_id = aws_route_table.private_rt_gozie_tf.id
}

*/
# first rds subnet

resource "aws_subnet" "public_subnet_gozie_project_rds" {
  vpc_id                  = aws_vpc.gozie_project_vpc.id
  cidr_block              = "10.0.64.0/19"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1c"
  tags = {
    "Name" = "public_sub_gozie_rds"

  }
}

# Route Table for the RDS Public Subnet

resource "aws_route_table" "public_rt_gozie_rds" {
  vpc_id = aws_vpc.gozie_project_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gozie_project_igw.id
  }
  tags = {
    Name = "public_subnet_route-table_gozie_project_rds"
  }
}

# This route table is associated with the public subnet and routes traffic to the Internet Gateway.
# It allows resources in the public subnet to access the internet.

resource "aws_route_table_association" "public_sub_gozie_rds" {
  subnet_id      = aws_subnet.public_subnet_gozie_project_rds.id
  route_table_id = aws_route_table.public_rt_gozie_rds.id
}

# second rds subnet

resource "aws_subnet" "public_subnet_gozie_project_rds2" {
  vpc_id                  = aws_vpc.gozie_project_vpc.id
  cidr_block              = "10.0.96.0/19"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1d"
  tags = {
    "Name" = "public_sub_gozie_rds2"

  }
}

# Route Table for the RDS Public Subnet

resource "aws_route_table" "public_rt_gozie_rds2" {
  vpc_id = aws_vpc.gozie_project_vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gozie_project_igw.id
  }
  tags = {
    Name = "public_subnet_route-table_gozie_project_rds2"
  }
}

# This route table is associated with the public subnet and routes traffic to the Internet Gateway.
# It allows resources in the public subnet to access the internet.

resource "aws_route_table_association" "public_sub_gozie_rds2" {
  subnet_id      = aws_subnet.public_subnet_gozie_project_rds2.id
  route_table_id = aws_route_table.public_rt_gozie_rds2.id
}



# security group for the VPC
resource "aws_security_group" "sg_gozie_tf" {
  name        = "gozie_tf_sg"
  description = "Security group for Gozie Terraform setup"
  vpc_id      = aws_vpc.gozie_project_vpc.id

  ingress {
    description      = "sg_gozie_tf_https"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    #cidr_blocks = [aws_vpc.gozie_tf.cidr_block]
  }

  ingress {
    description = "sg_gozie_tf_http"
    # This rule allows HTTP traffic on port 80 from the VPC CIDR block
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    #cidr_blocks = [aws_vpc.gozie_tf.cidr_block]
  }

  ingress {
    description = "Allow Redshift access from external SQL clients"
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Redshift access from external RDS clients"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "sg_gozie_tf_ssh"
    # This rule allows HTTP traffic on port 80 from the VPC CIDR block
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "gozie_tf_sg"
  }
}