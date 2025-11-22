variable "namespace" {
  type        = string
  description = "The namespace to use for project resources"
  default     = "consensys"
}

variable "region" {
  type        = string
  description = "The AWS region to create resources in"
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

