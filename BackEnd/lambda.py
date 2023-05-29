import boto3
import json
import decimal

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('siteCounter')
# update counter in dynamodb table

    response = table.update_item(
        TableName='siteCounter',
        Key={
            'counter' : 'view-count'
        },
        ExpressionAttributeNames={
            '#Q': 'quantity'
        },
        ExpressionAttributeValues={
        ':val': 1
        },
        UpdateExpression='SET #Q = #Q + :val',
        ReturnValues="UPDATED_NEW"
    )
    response = {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'OPTIONS,POST',
            'Access-Control-Allow-Headers': '*',
            'Content-Type': 'application/json',
            },
        
        'body': json.dumps(int(response['Attributes']['quantity']))
        }
    return response