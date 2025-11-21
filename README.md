# Folder structure
```
terraform-modules/
├── README.md
├── LICENSE
├── .gitignore
├── examples/
│   ├── aws/
│   │   ├── complete/
│   │   ├── simple/
│   │   └── README.md
│   ├── azure/
│   │   ├── complete/
│   │   ├── simple/
│   │   └── README.md
│   └── gcp/
│       ├── complete/
│       ├── simple/
│       └── README.md
│
├── modules/
│   ├── aws/
│   │   ├── compute/
│   │   │   ├── ec2/                  # EC2 instances
│   │   │   │   ├── main.tf
│   │   │   │   ├── variables.tf
│   │   │   │   ├── outputs.tf
│   │   │   │   ├── versions.tf
│   │   │   │   └── README.md
│   │   │   ├── ecs/                  # ECS cluster & services
│   │   │   ├── eks/                  # EKS cluster
│   │   │   ├── lambda/               # Lambda functions
│   │   │   └── asg/                  # Auto Scaling Groups
│   │   │
│   │   ├── networking/
│   │   │   ├── vpc/                  # VPC and subnets
│   │   │   ├── security-group/       # Security Groups
│   │   │   ├── alb/                  # Application Load Balancer
│   │   │   ├── nlb/                  # Network Load Balancer
│   │   │   ├── nat-gateway/
│   │   │   └── vpc-peering/
│   │   │
│   │   ├── storage/
│   │   │   ├── s3/                   # S3 buckets
│   │   │   ├── efs/                  # Elastic File System
│   │   │   └── ebs/                  # EBS volumes
│   │   │
│   │   ├── database/
│   │   │   ├── rds/                  # RDS instances
│   │   │   ├── dynamodb/             # DynamoDB tables
│   │   │   ├── elasticache/          # Redis/Memcached
│   │   │   └── aurora/               # Aurora clusters
│   │   │
│   │   ├── security/
│   │   │   ├── iam/                  # IAM roles & policies
│   │   │   ├── kms/                  # KMS keys
│   │   │   ├── secrets-manager/
│   │   │   └── waf/                  # Web Application Firewall
│   │   │
│   │   ├── monitoring/
│   │   │   ├── cloudwatch/           # CloudWatch logs & metrics
│   │   │   └── sns/                  # SNS topics
│   │   │
│   │   └── dns/
│   │       └── route53/              # Route53 zones & records
│   │
│   ├── azure/
│   │   ├── compute/
│   │   │   ├── vm/                   # Virtual Machines
│   │   │   ├── vmss/                 # VM Scale Sets
│   │   │   ├── aks/                  # Azure Kubernetes Service
│   │   │   ├── container-instance/   # Container Instances
│   │   │   └── function-app/         # Azure Functions
│   │   │
│   │   ├── networking/
│   │   │   ├── vnet/                 # Virtual Network
│   │   │   ├── subnet/               # Subnets
│   │   │   ├── nsg/                  # Network Security Groups
│   │   │   ├── application-gateway/  # Application Gateway
│   │   │   ├── load-balancer/
│   │   │   └── vnet-peering/
│   │   │
│   │   ├── storage/
│   │   │   ├── storage-account/      # Storage Accounts
│   │   │   ├── blob-container/
│   │   │   └── file-share/
│   │   │
│   │   ├── database/
│   │   │   ├── sql-database/         # Azure SQL Database
│   │   │   ├── postgresql/           # PostgreSQL
│   │   │   ├── mysql/                # MySQL
│   │   │   └── cosmos-db/            # Cosmos DB
│   │   │
│   │   ├── security/
│   │   │   ├── key-vault/            # Key Vault
│   │   │   ├── managed-identity/     # Managed Identities
│   │   │   └── rbac/                 # Role-Based Access Control
│   │   │
│   │   ├── monitoring/
│   │   │   ├── log-analytics/
│   │   │   └── application-insights/
│   │   │
│   │   └── dns/
│   │       └── dns-zone/             # DNS Zones
│   │
│   └── gcp/
│       ├── compute/
│       │   ├── compute-instance/     # Compute Engine instances
│       │   ├── instance-group/       # Instance Groups
│       │   ├── gke/                  # Google Kubernetes Engine
│       │   ├── cloud-run/            # Cloud Run
│       │   └── cloud-functions/      # Cloud Functions
│       │
│       ├── networking/
│       │   ├── vpc/                  # VPC Network
│       │   ├── subnet/               # Subnets
│       │   ├── firewall/             # Firewall rules
│       │   ├── load-balancer/        # Load Balancers
│       │   └── vpc-peering/
│       │
│       ├── storage/
│       │   ├── gcs/                  # Cloud Storage buckets
│       │   └── persistent-disk/      # Persistent Disks
│       │
│       ├── database/
│       │   ├── cloud-sql/            # Cloud SQL
│       │   ├── firestore/            # Firestore
│       │   ├── bigtable/             # Bigtable
│       │   └── spanner/              # Spanner
│       │
│       ├── security/
│       │   ├── iam/                  # IAM roles & policies
│       │   ├── kms/                  # Cloud KMS
│       │   └── secret-manager/       # Secret Manager
│       │
│       ├── monitoring/
│       │   ├── logging/              # Cloud Logging
│       │   └── monitoring/           # Cloud Monitoring
│       │
│       └── dns/
│           └── cloud-dns/            # Cloud DNS
│
└── tests/                             # Terratest or testing
    ├── aws/
    ├── azure/
    └── gcp/
```

## submodule
```
module-name/
├── main.tf          # Resource definitions
├── variables.tf     # Input variables
├── outputs.tf       # Output values
├── versions.tf      # Terraform & provider version constraints
├── README.md        # Documentation
├── locals.tf        # Local values (optional)
└── data.tf          # Data sources (optional)
```
