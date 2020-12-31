
# set the required version of terraform and providers
terraform {
  required_version = "~> 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    sumologic = {
      source  = "SumoLogic/sumologic"
      version = "~> 2.0"
    }
  }
}
