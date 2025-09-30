aws_region   = "us-east-1"
project_name = "kafka-eks-project"
environment  = "dev"

eks_cluster_version = "1.32"
rds_postgres_version = "17.4"
rds_instance_class = "db.t3.micro"

db_name     = "postgres"
db_username = "postgres"

enable_cross_region_replication = false