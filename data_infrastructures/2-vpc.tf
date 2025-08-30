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
    Name        = "public_subnet_gozie_project2"
    Environment = "Dev"

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
    Name        = "public_subnet_route-table_gozie_project2"
    Environment = "Dev"
  }
}

resource "aws_route_table_association" "public_sub_gozie_tf2" {
  subnet_id      = aws_subnet.public_subnet_gozie_project2.id
  route_table_id = aws_route_table.public_rt_gozie_tf2.id
}


resource "aws_subnet" "public_subnet_gozie_project_rds" {
  vpc_id                  = aws_vpc.gozie_project_vpc.id
  cidr_block              = "10.0.64.0/19"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1c"
  tags = {
    Name        = "public_sub_gozie_rds"
    Environment = "Dev"

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
    Name        = "public_subnet_route-table_gozie_project_rds"
    Environment = "Dev"
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
    Name        = "public_sub_gozie_rds2"
    Environment = "Dev"

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
    Name        = "public_subnet_route-table_gozie_project_rds2"
    Environment = "Dev"
  }
}

# This route table is associated with the public subnet and routes traffic to the Internet Gateway.
# It allows resources in the public subnet to access the internet.

resource "aws_route_table_association" "public_sub_gozie_rds2" {
  subnet_id      = aws_subnet.public_subnet_gozie_project_rds2.id
  route_table_id = aws_route_table.public_rt_gozie_rds2.id
}



# security group for the redshift cluster
resource "aws_security_group" "sg_gozie_tf" {
  name        = "gozie_tf_sg"
  description = "Security group for Redshift cluster"
  vpc_id      = aws_vpc.gozie_project_vpc.id
  tags = {
    Name        = "gozie_tf_sg"
    Environment = "Dev"
  }
}

# Ingress rules for redshift security group
resource "aws_security_group_rule" "sg_ingress_https" {
  security_group_id = aws_security_group.sg_gozie_tf.id
  type              = "ingress"
  description       = "Allow HTTPS traffic from VPC CIDR block"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sg_ingress_http" {
  security_group_id = aws_security_group.sg_gozie_tf.id
  type              = "ingress"
  description       = "This rule allows HTTP traffic on port 80 from the VPC CIDR block"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sg_ingress_sql" {
  security_group_id = aws_security_group.sg_gozie_tf.id
  type              = "ingress"
  description       = "Allow Redshift access from external SQL clients"
  from_port         = 5439
  to_port           = 5439
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sg_ingress_rds" {
  security_group_id = aws_security_group.sg_gozie_tf.id
  type              = "ingress"
  description       = "Allow Redshift access from external RDS clients"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sg_ingress_ssh" {
  security_group_id = aws_security_group.sg_gozie_tf.id
  type              = "ingress"
  description       = "This rule allows HTTP traffic on port 80 from the VPC CIDR block"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Egress rules for redshift security group
resource "aws_security_group_rule" "sg_egress_all" {
  security_group_id = aws_security_group.sg_gozie_tf.id
  type              = "egress"
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
