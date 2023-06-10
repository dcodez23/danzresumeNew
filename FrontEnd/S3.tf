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
  website_files = fileset(path.module, "WebSiteFiles/**")

  content_type_map = {
    "html" = "text/html",
    "css"  = "text/css",
    "js"   = "application/javascript",
    "png"  = "image/png",
    "jpg"  = "image/jpeg"
    # Add more mappings as needed
  }
}

resource "aws_s3_bucket_object" "s3_upload" {
  for_each = fileset("${path.root}/WebSiteFiles", "**/*")

  bucket = aws_s3_bucket.bucketSiteName.id
  key    = each.value
  source = "${path.root}/WebSiteFiles/${each.value}"

  etag         = filemd5("${path.root}/WebSiteFiles/${each.value}")
  content_type = lookup(local.content_type_map, regex("\\.[^.]+$", each.value), null) # if none found default to null (will result in binary/octet-stream)
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

