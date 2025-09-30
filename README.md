# Kafka EKS Infrastructure - Terraform

This Terraform configuration provisions a complete Kafka infrastructure on AWS EKS including:
- VPC with public/private subnets
- EKS cluster with compute-optimized node groups for Kafka
- RDS PostgreSQL database
- ECR repositories for container images

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- kubectl
- helm

## Project Structure

```
terraform/
├── main.tf                 # Main configuration
├── variables.tf            # Input variables
├── outputs.tf             # Output values
├── terraform.tfvars       # Variable values (create this)
├── modules/
│   ├── vpc/              # VPC module
│   ├── eks/              # EKS cluster module
│   ├── rds/              # RDS database module
│   └── ecr/              # ECR repositories module
```

## Usage

### 1. Initialize Terraform

```bash
cd terraform
terraform init
```

### 2. Create terraform.tfvars

Create a `terraform.tfvars` file with your configuration:

```hcl
aws_region   = "us-east-1"
project_name = "kafka-eks-project"
environment  = "dev"

eks_cluster_version = "1.32"
rds_postgres_version = "17.4"
rds_instance_class = "db.t3.micro"

db_name     = "postgres"
db_username = "postgres"
```

### 3. Plan the Infrastructure

```bash
terraform plan
```

Review the planned changes to ensure everything looks correct.

### 4. Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted. This will take approximately 15-20 minutes.

### 5. Configure kubectl

After the cluster is created, configure kubectl:

```bash
aws eks update-kubeconfig --region us-east-1 --name kafka-eks-project-dev
```

Test the connection:

```bash
kubectl get nodes
```

### 6. Get Database Password

The database password is stored in AWS Secrets Manager:

```bash
# Get the secret ARN from outputs
terraform output rds_password_secret_arn

# Retrieve the password
aws secretsmanager get-secret-value \
    --secret-id <SECRET_ARN> \
    --query SecretString \
    --output text | jq -r '.password'
```

## Infrastructure Components

### VPC
- CIDR: 10.0.0.0/16
- 3 Public subnets
- 3 Private subnets
- NAT Gateways for internet access from private subnets

### EKS Cluster
- Kubernetes version: 1.32
- Two node groups:
  - **kafka-nodes**: c5.large (3-6 nodes) - for Kafka workloads
  - **general-nodes**: t3.medium (2-4 nodes) - for other workloads

### RDS PostgreSQL
- Engine: PostgreSQL 17.4
- Instance: db.t3.micro (adjustable)
- Storage: 20GB with auto-scaling up to 100GB
- Encrypted storage
- Automated backups (7 days retention)
- Performance Insights enabled

### ECR Repositories
- kafka-producer
- kafka-consumer-api
- kafka-dashboard

## Important Outputs

After applying, you'll get these outputs:

```bash
# View all outputs
terraform output

# View specific output
terraform output eks_cluster_endpoint
terraform output rds_endpoint
terraform output ecr_repository_urls
```

## Cost Optimization

To minimize costs when not actively using the cluster:

```bash
# Destroy everything
terraform destroy

# Or scale down node groups
terraform apply -var="node_groups={}"
```

## Updating Infrastructure

To modify the infrastructure:

1. Edit the relevant `.tf` files or `terraform.tfvars`
2. Run `terraform plan` to see changes
3. Run `terraform apply` to apply changes

## Troubleshooting

### EKS Cluster Access Issues

If you can't access the cluster:

```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name kafka-eks-project-dev

# Verify AWS credentials
aws sts get-caller-identity

# Check cluster status
aws eks describe-cluster --name kafka-eks-project-dev --region us-east-1
```

### RDS Connection Issues

Ensure your EKS security group allows connections to RDS:

```bash
# Get security groups
terraform output

# RDS is configured to accept connections from the entire VPC CIDR (10.0.0.0/16)
```

### State Management

For production, use remote state storage:

```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "kafka-eks/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}
```

## Cleanup

To destroy all resources:

```bash
# Delete Kubernetes resources first
kubectl delete namespace kafka

# Then destroy Terraform resources
terraform destroy
```

**Warning**: This will permanently delete all resources including data in RDS!

## Next Steps

After infrastructure is provisioned:

1. Install Strimzi Kafka operator
2. Deploy Kafka cluster
3. Deploy your applications (producer, consumer, dashboard)
4. Set up monitoring with Prometheus/Grafana
5. Configure ArgoCD for GitOps

## Security Notes

- Database passwords are stored in AWS Secrets Manager
- All outputs containing sensitive data are marked as sensitive
- RDS is not publicly accessible by default
- EKS uses IAM for authentication
- ECR repositories have image scanning enabled

## Support

For issues or questions, refer to:
- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)