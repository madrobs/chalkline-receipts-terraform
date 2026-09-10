environment              = "prod"
aws_region               = "us-east-1"
vpc_cidr                 = "10.40.0.0/16"
private_subnet_cidrs     = ["10.40.10.0/24", "10.40.11.0/24", "10.40.12.0/24"]
receipts_desired_count   = 3
storage_desired_count    = 2
member_api_desired_count = 3
