locals {
  name = "chalkline-${var.environment}"

  services = {
    receipts = {
      name          = "receipts-api"
      port          = 3000
      desired_count = var.receipts_desired_count
    }
    storage = {
      name          = "chalkline-storage"
      port          = 4000
      desired_count = var.storage_desired_count
    }
    members = {
      name          = "member-api"
      port          = 3001
      desired_count = var.member_api_desired_count
    }
  }

  common_tags = {
    Company     = "Chalkline Athletics"
    Environment = var.environment
    ManagedBy   = "terraform"
    Platform    = "chalkline"
  }
}
