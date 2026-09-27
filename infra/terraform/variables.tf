variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "ecr_repository" {
  type    = string
  default = "my-app"
}

variable "eks_cluster_name" {
  type        = string
  description = "Name of an existing EKS cluster"
}

variable "github_repo" {
  type        = string
  description = "GitHub repo in OWNER/NAME form"
  default     = "thesayaksarkar/my-app"
}

variable "create_github_oidc_provider" {
  type        = bool
  description = "Set false if GitHub OIDC provider already exists in the account"
  default     = true
}
