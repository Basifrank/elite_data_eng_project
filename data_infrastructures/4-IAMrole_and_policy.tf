# This configuration creates an IAM role and attaches a custom policy to Redshift.
resource "aws_iam_policy" "redshift_custom_s3_policy" {
  name        = "redshift_s3_policy"
  description = "Allows specific S3 actions with conditions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # {
      #   Effect   = "Allow"
      #   Action   = "s3:ListBucket"
      #   Resource = "arn:aws:s3:::goziestimulateddata/*"
      #   Condition = {
      #     StringEquals = {
      #       "s3:prefix" = "goziestimulateddata"
      #     }
      #   }
      # },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::goziestimulateddata/*",
        ]
      },
    ]
  })
}

resource "aws_iam_role" "redshift_iam_role" {
  name = "redshift-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "redshift.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "redshift_s3_access" {
  role       = aws_iam_role.redshift_iam_role.name
  policy_arn = aws_iam_policy.redshift_custom_s3_policy.arn
}

