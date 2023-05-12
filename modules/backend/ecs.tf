data "template_file" "containerised_task_definition" {
  template = file("./modules/backend/task-definition.json")
  vars = {
    REGION     = var.aws_region
    IMAGE_ADDR = "${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.service}-${var.build_stage}-${var.ecs_service}:latest"
    SERVICE    = var.service
    STAGE      = var.build_stage
    APP        = var.ecs_service
  }
}

resource "aws_ecs_task_definition" "containerised" {
  family                   = "${var.service}-${var.build_stage}-task-definition"
  container_definitions    = data.template_file.containerised_task_definition.rendered
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  task_role_arn            = var.task_role_arn
  execution_role_arn       = "arn:aws:iam::${var.account_id}:role/ecsTaskExecutionRole"
  requires_compatibilities = ["FARGATE"]
  tags                     = var.tags
}

resource "aws_ecs_service" "containerised" {
  name            = "${var.service}-${var.build_stage}-ecs-service-${var.ecs_service}"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.containerised.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  tags            = var.tags

  network_configuration {
    security_groups  = [var.ecs_security_group]
    subnets          = var.private_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.containerised_fargate_targetgroup.arn
    container_name   = "${var.service}-${var.build_stage}-${var.ecs_service}"
    container_port   = var.container_port
  }
}

resource "aws_cloudwatch_log_group" "ecs_task_logs" {
  name = "/ecs/${var.service}-${var.build_stage}-${var.ecs_service}-task-logs"
  tags = var.tags
}
