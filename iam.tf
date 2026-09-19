data "aws_iam_policy_document" "assume_ecs" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "receipts_api" {
  name               = "${local.name}-receipts-api"
  assume_role_policy = data.aws_iam_policy_document.assume_ecs.json

  tags = merge(local.common_tags, {
    Service = "receipts-api"
  })
}

resource "aws_iam_role" "storage" {
  name               = "${local.name}-chalkline-storage"
  assume_role_policy = data.aws_iam_policy_document.assume_ecs.json

  tags = merge(local.common_tags, {
    Service = "chalkline-storage"
  })
}

resource "aws_iam_role" "member_api" {
  name               = "${local.name}-member-api"
  assume_role_policy = data.aws_iam_policy_document.assume_ecs.json

  tags = merge(local.common_tags, {
    Service = "member-api"
  })
}

data "aws_iam_policy_document" "storage" {
  # Least privilege: reprints only. The thermal printer at the desk
  # already has the PDF; the storage service should not mint new objects in prod.
  statement {
    sid = "ReceiptsBucketAccess"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.receipts.arn}/*",
    ]
  }
}

resource "aws_iam_role_policy" "storage" {
  name   = "${local.name}-chalkline-storage-s3"
  role   = aws_iam_role.storage.id
  policy = data.aws_iam_policy_document.storage.json
}
