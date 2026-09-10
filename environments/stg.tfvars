environment              = "stg"
aws_region               = "us-east-1"
vpc_cidr                 = "10.30.0.0/16"
private_subnet_cidrs     = ["10.30.10.0/24", "10.30.11.0/24"]
receipts_desired_count   = 1
storage_desired_count    = 1
member_api_desired_count = 1
