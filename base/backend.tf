# resource "aws_s3_bucket" "tfbackend" {
#   bucket = "tfstate"
#   versioning {
#     enabled = true
#   }
#   lifecycle {
#     prevent_destroy = true
#   }
# #   tags {
# #     Name = "S3 Remote Terraform State Store"
# #   }
# }
# create a dynamodb table for locking the state file
resource "aws_dynamodb_table" "tflock" {
  name           = "tflock"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  #   tags {
  #     Name = "DynamoDB Terraform State Lock Table"
  #   }
}