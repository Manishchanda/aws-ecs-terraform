variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_count" {
  type    = number
  default = 2
}

variable "private_count" {
  type    = number
  default = 2
}

variable "create_nat_gateway" {
  description = "Whether to create a NAT gateway for private subnet outbound access"
  type        = bool
  default     = true
}
