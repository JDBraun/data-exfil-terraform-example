// Cross Account Role
data "databricks_aws_assume_role_policy" "this" {
  external_id = var.databricks_account_id
}

resource "aws_iam_role" "cross_account_role" {
  name               = "${local.prefix}-crossaccount"
  assume_role_policy = data.databricks_aws_assume_role_policy.this.json
  tags = {
    Name = "${local.prefix}-crossaccount-role"
  }
}

resource "aws_iam_role_policy" "crossaccount" {
  name   = "${local.prefix}-crossaccount-policy"
  role   = aws_iam_role.cross_account_role.id
  policy = jsonencode({Version: "2012-10-17",
            Statement: [
              {
                "Sid": "Stmt1403287045000",
                "Effect": "Allow",
                "Action": [
                  "ec2:AssociateIamInstanceProfile",
                  "ec2:AttachVolume",
                  "ec2:AuthorizeSecurityGroupEgress",
                  "ec2:AuthorizeSecurityGroupIngress",
                  "ec2:CancelSpotInstanceRequests",
                  "ec2:CreateTags",
                  "ec2:CreateVolume",
                  "ec2:DeleteTags",
                  "ec2:DeleteVolume",
                  "ec2:DescribeAvailabilityZones",
                  "ec2:DescribeIamInstanceProfileAssociations",
                  "ec2:DescribeInstanceStatus",
                  "ec2:DescribeInstances",
                  "ec2:DescribeInternetGateways",
                  "ec2:DescribeNatGateways",
                  "ec2:DescribeNetworkAcls",
                  "ec2:DescribePrefixLists",
                  "ec2:DescribeReservedInstancesOfferings",
                  "ec2:DescribeRouteTables",
                  "ec2:DescribeSecurityGroups",
                  "ec2:DescribeSpotInstanceRequests",
                  "ec2:DescribeSpotPriceHistory",
                  "ec2:DescribeSubnets",
                  "ec2:DescribeVolumes",
                  "ec2:DescribeVpcAttribute",
                  "ec2:DescribeVpcs",
                  "ec2:DetachVolume",
                  "ec2:DisassociateIamInstanceProfile",
                  "ec2:ReplaceIamInstanceProfileAssociation",
                  "ec2:RequestSpotInstances",
                  "ec2:RevokeSecurityGroupEgress",
                  "ec2:RevokeSecurityGroupIngress",
                  "ec2:RunInstances",
                  "ec2:TerminateInstances"
                ],
                Resource: [
                  "*"
                ]
              },
              {
                Effect: "Allow",
                Action: [
                  "iam:CreateServiceLinkedRole",
                  "iam:PutRolePolicy"
                ],
                Resource: "arn:aws:iam::*:role/aws-service-role/spot.amazonaws.com/AWSServiceRoleForEC2Spot",
                Condition: {
                  StringLike: {
                    "iam:AWSServiceName": "spot.amazonaws.com"
                  }
                }
              }
            ]
          }
  )
}


// Unity Catalog Role
data "aws_iam_policy_document" "passrole_for_unity_catalog" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL"]
      type        = "AWS"
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.databricks_account_id]
    }
  }
  statement {
    sid     = "ExplicitSelfRoleAssumption"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::${var.aws_account_id}:role/${local.prefix}-unitycatalog"]
    }
  }
}

resource "aws_iam_role" "unity_catalog_role" {
  name  = "${local.prefix}-unitycatalog"
  assume_role_policy = data.aws_iam_policy_document.passrole_for_unity_catalog.json
}


resource "aws_iam_role_policy" "unity_catalog" {
  name   = "${local.prefix}-unitycatalog-policy"
  role   = aws_iam_role.unity_catalog_role.id
  policy = jsonencode({Version: "2012-10-17",
            Statement: [
                    {
                        "Action": [
                            "s3:GetObject",
                            "s3:PutObject",
                            "s3:DeleteObject",
                            "s3:ListBucket",
                            "s3:GetBucketLocation",
                            "s3:GetLifecycleConfiguration",
                            "s3:PutLifecycleConfiguration"
                        ],
                        "Resource": [
                            "arn:aws:s3:::${aws_s3_bucket.unity_catalog_bucket.id}/*",
                            "arn:aws:s3:::${aws_s3_bucket.unity_catalog_bucket.id}"
                        ],
                        "Effect": "Allow"
                    },
                    {
                        "Action": [
                            "sts:AssumeRole"
                        ],
                        "Resource": [
                            "arn:aws:iam::${local.account_id}:role/${local.prefix}-unitycatalog"
                        ],
                        "Effect": "Allow"
                    }
                  ]
          }
  )
}