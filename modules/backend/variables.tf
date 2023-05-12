variable "ecs_service" {
  description = "Name of the ECS Service"
}

variable "cpu" {
  description = "CPU Amount for Service"
}

variable "memory" {
  description = "Memory Amount for Service"
}

variable "container_port" {
  description = "Entry port for ECS container"
  default = 80
}

variable "cluster_id" {
  description = "ID for ECS cluster"
}

variable "ecs_security_group" {
  description = "ARN of security group (created externally in fargate-sg.tf)"
}

variable "task_role_arn" {
  description = "ARN for Task Role IAM"
}

variable "lb_tg_port" {
  description = "Load Balancer target group port"
}

variable "lb_health_path" {
  description = "Path for ALB health check"
}

variable "lb_listener_port" {
  description = "Load Balancer listener port"
}

variable "lb_sg" {
  description = "ARN of security group (created externally in alb-sg.tf)"
}

variable "waf_arn" {
  description = "ARN for WAF resource defined externally (waf.tf)"
}

variable "dns_zone" {
  description = "DNS Zone value specified in main.tf"
}

variable "domain_base" {
  description = "Domain Base value specified in main.tf"
}

variable "vpc_id" {
  description = "ID for VPC - created in network.tf"
}

variable "public_subnets" {
  description = "Public Subnets in VPC"
}

variable "private_subnets" {
  description = "Private Subnets in VPC"
}

variable "account_id" {
}

variable "aws_region" {
}

variable "service" {
}

variable "build_stage" {
}

variable "tags" {
}