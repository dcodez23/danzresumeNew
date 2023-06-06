terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = "us-east-1"
  #profile = "prod"
  access_key = AWS_ACCESS_KEY_ID
  secret_key = AWS_SECRET_ACCESS_KEY
}

/*terraform {
  cloud {
    organization = "CloudResumeDZ"

    workspaces {
      name = "CloudResumeBackend"
    }
  }
}
*/