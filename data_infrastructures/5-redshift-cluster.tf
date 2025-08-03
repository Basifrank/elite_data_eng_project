

# Create Redshift Subnet Group

resource "aws_redshift_subnet_group" "redshift_subnet_group" {
    name       = "redshift-subnet-group"
    subnet_ids = [aws_subnet.public_subnet_gozie_project.id, aws_subnet.public_subnet_gozie_project2.id]
    description = "Redshift subnet group for cluster"
    tags = {
        Name = "redshift-subnet-group"
    }

    depends_on = [aws_vpc.gozie_project_vpc]
}


resource "random_password" "password" {
  length           = 16
  special          = true
  min_numeric      = 1 
  numeric = true
  override_special = "!$%&*()-_=+[]{}<>:?"
}


# Create Redshift Parameter Group
resource "aws_redshift_parameter_group" "bar" {
  name   = "parameter-group-test-terraform"
  family = "redshift-2.0"

  parameter {
    name  = "require_ssl"
    value = "false"
  }

}



# Create Redshift Cluster: Define the aws_redshift_cluster resource
    resource "aws_redshift_cluster" "redshift_cluster" {
      cluster_identifier  = "my-redshift-cluster"
      node_type           = "ra3.large" 
      cluster_type        = "multi-node" 
      number_of_nodes     = 2 
      #cluster_type        = "single-node" 
      #number_of_nodes    =  2
      master_username     = "admin"
      master_password     = random_password.password.result 
      database_name       = "mydatabase"
      publicly_accessible = true
      enhanced_vpc_routing = true
      cluster_parameter_group_name = aws_redshift_parameter_group.bar.name
      cluster_subnet_group_name = aws_redshift_subnet_group.redshift_subnet_group.name
      vpc_security_group_ids = [aws_security_group.sg_gozie_tf.id]
      iam_roles           = [aws_iam_role.redshift_iam_role.arn]
      skip_final_snapshot = true # For development, set to false for productiony
      tags = {
        Name = "MyRedshiftCluster"
      }
    }