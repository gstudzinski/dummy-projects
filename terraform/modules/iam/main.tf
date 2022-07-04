resource "aws_iam_role" "ecs_execution_task_role" {
  name                = "${var.mod_prefix}-ecsExecutionTaskRole"
  assume_role_policy  = data.aws_iam_policy_document.this.json # (not shown)
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ]
}

data aws_iam_policy_document "this" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}