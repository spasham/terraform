variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for Ubuntu image"
  type        = string
}

variable "instance_name" {
  description = "Tag name for the EC2 instance"
  type        = string
}

variable "key_pair_name" {
  description = "Name for SSH Key Pair"
  type        = string
}
