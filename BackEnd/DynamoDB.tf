resource "aws_dynamodb_table" "siteCountTable" {
  name           = "siteCounter"
  billing_mode   = "PROVISIONED"
  stream_enabled = false
  hash_key       = "counter"
  read_capacity  = 1
  write_capacity = 1
  ttl {
    attribute_name = ""
    enabled        = false
  }
  point_in_time_recovery {
    enabled = false
  }
  attribute {
    name = "counter"
    type = "S"
  }

}

resource "aws_dynamodb_table_item" "quantity" {
  table_name = aws_dynamodb_table.siteCountTable.name
  hash_key   = aws_dynamodb_table.siteCountTable.hash_key

  item = <<ITEM
  {
    "counter" : {"S" : "view-count"},
    "quantity" : {"N" : "0"}
  }
  ITEM
}