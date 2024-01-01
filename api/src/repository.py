import boto3
import datetime
import uuid
import config


ydb_docapi_client = boto3.resource('dynamodb',
                                    endpoint_url=config.DOCUMENT_API_ENDPOINT,
                                    region_name=config.REGION,
                                    aws_access_key_id=config.ACCESS_KEY_ID,
                                    aws_secret_access_key=config.SECRET_ACCESS_KEY)


def put_feedback(username: str, text: str):
    table = ydb_docapi_client.Table('feedback')

    response = table.put_item(
      Item = {
            'id': str(uuid.uuid4()),
            'username': username,
            'datetime': str(datetime.datetime.now()),
            'text': text
        }
    )

    return response


def get_feedback():
    table = ydb_docapi_client.Table('feedback')

    response = table.scan()

    return response


def get_replica_id():
    table = ydb_docapi_client.Table('replica')

    response = table.update_item(Key={'key': 0},
                                 ReturnValues="UPDATED_NEW",
                                 ExpressionAttributeValues={":inc": 1},
                                 UpdateExpression='ADD value :inc',)
    
    return response['Attributes'].get('value', 0)