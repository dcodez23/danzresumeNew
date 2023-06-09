resource "aws_s3_bucket" "bucketSiteName" {
  bucket = var.bucketName
  tags = {
    Name        = "SiteBucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.bucketSiteName.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}


locals {
  website_files = [for file in fileset("./WebSiteFiles/", "**") : file if file != "assets/.DS_Store"]
}

resource "aws_s3_bucket_object" "object" {
  bucket        = aws_s3_bucket.bucketSiteName.id
  for_each      = toset(local.website_files)
  key           = each.value
  source        = "./WebSiteFiles/${each.value}"
  content_type  = coalesce(var.content_types[regex("(\\.[^.]+)$", each.value)[0]], var.default_content_type)
  etag          = filemd5("./WebSiteFiles/${each.value}")
}


variable "content_types" {
  type = map(string)

  default = {
    ".html" = "text/html"
    ".css"  = "text/css"
    ".js"   = "application/javascript"
    ".jpg"  = "image/jpeg"
    ".ico"  = "image/png"
  }
}

variable "default_content_type" {
  type    = string
  default = "application/octet-stream"
}

resource "aws_s3_bucket_public_access_block" "danzPublic" {
  bucket = aws_s3_bucket.bucketSiteName.id

  block_public_acls   = false
  block_public_policy = false
}

resource "aws_s3_bucket_policy" "danzBucketPolicy" {
  bucket = aws_s3_bucket.bucketSiteName.id
  policy = data.aws_iam_policy_document.danzPolicy.json
}

data "aws_iam_policy_document" "danzPolicy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      aws_s3_bucket.bucketSiteName.arn,
      "${aws_s3_bucket.bucketSiteName.arn}/*",
    ]
  }
}

