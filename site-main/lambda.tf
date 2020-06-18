# Adapted from https://github.com/twstewart42/terraform-aws-cloudfront-s3-website-lambda-edge/
# and https://adamj.eu/tech/2019/04/15/scoring-a+-for-security-headers-on-my-cloudfront-hosted-static-website/

provider "aws" {
  region = "us-east-1"
  alias  = "aws_cloudfront"
}

resource "random_id" "id" {
  keepers = {
    timestamp = timestamp() # force change on every execution
  }
  byte_length = 4
}

data "archive_file" "lambda_zip_inline" {
  type        = "zip"
  output_path = "/tmp/lambda_zip_inline_${var.bucket_name}.${random_id.id.dec}.zip"
  source {
    content  = <<EOF
'use strict';
exports.handler = (event, context, callback) => {
    const response = event.Records[0].cf.response;
    const headers = response.headers;

    %{if var.enable_hsts}
    headers['strict-transport-security'] = [{
      key: 'Strict-Transport-Security',
      value: 'max-age=${var.custom_headers_hsts_max_age}%{if var.enable_hsts_subdomains}; includeSubdomains%{endif}%{if var.enable_hsts_preload}; preload%{endif}'
    }];
    %{endif}

    headers['x-content-type-options'] = [{
      key: 'X-Content-Type-Options',
      value: 'nosniff'
    }];

    headers['x-frame-options'] = [{
      key: 'X-Frame-Options',
      value: 'DENY'
    }];

    headers['x-xss-protection'] = [{
      key: 'X-XSS-Protection',
      value: '1; mode=block'
    }];

    headers['referrer-policy'] = [{
      key: 'Referrer-Policy',
      value: '${var.custom_headers_referrer_policy}'
    }];

    callback(null, response);
};
EOF
    filename = "main.js"
  }
}

resource "aws_iam_role_policy" "lambda_execution" {
  name_prefix = "lambda-execution-policy-"
  role        = aws_iam_role.lambda_execution.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:CreateLogGroup"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "lambda_execution" {
  name_prefix        = "lambda-execution-role-"
  description        = "Managed by Terraform"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "edgelambda.amazonaws.com",
          "lambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = local.tags
}

resource "aws_lambda_function" "set_headers" {
  description      = "Managed by Terraform"
  filename         = data.archive_file.lambda_zip_inline.output_path
  function_name    = "set_headers_${var.bucket_name}"
  handler          = "set_headers_${var.bucket_name}.handler"
  source_code_hash = data.archive_file.lambda_zip_inline.output_base64sha256
  provider         = aws.aws_cloudfront
  publish          = true
  role             = aws_iam_role.lambda_execution.arn
  runtime          = "nodejs12.x"

  tags = local.tags
}
