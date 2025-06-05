variable "subnet_ids" {
  description = "List of subnet IDs in different AZs"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "cluster_name" {
  default = "eks-cluster"
}

