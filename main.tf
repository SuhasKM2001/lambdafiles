provider "aws" {
  region = "us-east-1" # Change as needed
}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main_vpc"
  }
}

resource "aws_subnet" "main_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "main_subnet"
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main_igw"
  }
}

resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main_route_table"
  }
}

resource "aws_route_table_association" "main_route_table_assoc" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.main_route_table.id
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-lambda-accessible-bucket"

  tags = {
    Name = "my_s3_bucket"
  }
}

resource "aws_iam_role" "lambda_exec_role" {
  name               = "lambda_exec_role"
  assume_role_policy = "${file("assume_role_policy.json")}" # Define JSON separately
}

resource "aws_iam_policy" "lambda_s3_access_policy" {
  name   = "lambda_s3_access_policy"
  policy = "${file("policy.json")}" # Define JSON separately
}

resource "aws_security_group" "lambda_sg" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "lambda_sg"
  }
}
resource "aws_lambda_function" "my_lambda_function" {
  function_name = "my_lambda_function"
  role          = aws_iam_role.lambda_exec_role.arn
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"
  timeout       = 30

  vpc_config {
    subnet_ids         = [aws_subnet.main_subnet.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}
