resource "aws_api_gateway_rest_api" "counter" {
  name              = "counter"
  description       = "This is the site Counter API"
  put_rest_api_mode = "overwrite"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "lambdaCount" {
  parent_id   = aws_api_gateway_rest_api.counter.root_resource_id
  path_part   = "resource"
  rest_api_id = aws_api_gateway_rest_api.counter.id
}

resource "aws_api_gateway_method" "PostCount" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.lambdaCount.id
  rest_api_id   = aws_api_gateway_rest_api.counter.id
}

resource "aws_api_gateway_method_response" "corsMethodResponse" {
  http_method = aws_api_gateway_method.PostCount.http_method
  resource_id = aws_api_gateway_resource.lambdaCount.id
  rest_api_id = aws_api_gateway_rest_api.counter.id

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  depends_on  = [aws_api_gateway_method.PostCount]
  status_code = "200"
}

resource "aws_api_gateway_integration" "postIntegra" {
  http_method             = aws_api_gateway_method.PostCount.http_method
  resource_id             = aws_api_gateway_resource.lambdaCount.id
  rest_api_id             = aws_api_gateway_rest_api.counter.id
  type                    = "AWS"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.myFunction.invoke_arn
}

resource "aws_api_gateway_integration_response" "corsResponse" {
  http_method = aws_api_gateway_method.PostCount.http_method
  resource_id = aws_api_gateway_resource.lambdaCount.id
  rest_api_id = aws_api_gateway_rest_api.counter.id
  response_templates = {
    "application/json" = ""
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [
    aws_api_gateway_integration.postIntegra
  ]
  status_code = aws_api_gateway_method_response.corsMethodResponse.status_code
}
resource "aws_api_gateway_deployment" "deployAPI" {
  rest_api_id = aws_api_gateway_rest_api.counter.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.lambdaCount.id,
      aws_api_gateway_method.PostCount.id,
      aws_api_gateway_integration.postIntegra.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployAPI.id
  rest_api_id   = aws_api_gateway_rest_api.counter.id
  stage_name    = "prod"
}

resource "aws_lambda_permission" "apigwCounter" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.myFunction.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.counter.execution_arn}/*"
}

resource "aws_api_gateway_method" "optionsMethod" {
  rest_api_id   = aws_api_gateway_rest_api.counter.id
  resource_id   = aws_api_gateway_resource.lambdaCount.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# OPTIONS method response.
resource "aws_api_gateway_method_response" "options200" {
  rest_api_id = aws_api_gateway_rest_api.counter.id
  resource_id = aws_api_gateway_resource.lambdaCount.id
  http_method = aws_api_gateway_method.optionsMethod.http_method
  status_code = 200
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Headers" = true
  }
  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [aws_api_gateway_method.optionsMethod]
}

# OPTIONS integration.
resource "aws_api_gateway_integration" "optionsIntegration" {
  rest_api_id = aws_api_gateway_rest_api.counter.id
  resource_id = aws_api_gateway_resource.lambdaCount.id
  http_method = aws_api_gateway_method.optionsMethod.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200

        depends_on = [aws_api_gateway_method.optionsMethod]
      }
    )
  }
}

# OPTIONS integration response.
resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.counter.id
  resource_id = aws_api_gateway_resource.lambdaCount.id
  http_method = aws_api_gateway_method.optionsMethod.http_method
  status_code = aws_api_gateway_method_response.options200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.options200]
}