terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.33.0"
    }
  }
}

provider "aws" {
  # Configuration options
}

# All passwords in this repo are used as an example and should not be used in production.
#
provider "aws" {}