import logging
import requests
import uuid
import os
import json
from datetime import datetime
import azure.cosmos.documents as documents
import azure.cosmos.cosmos_client as cosmos_client
import azure.cosmos.exceptions as exceptions
from azure.cosmos.partition_key import PartitionKey

import azure.functions as func

'''
Requirements
Add a property called id with a GUID value
Add a property called timestamp with the current UTC date time

Use a data service to store the ratings information to the backend
Return the entire review JSON payload with the newly created id and timestamp
'''

'''
Sample data set
{
  "userId": "cc20a6fb-a91f-4192-874d-132493685376",
  "productId": "4c25613a-a3c2-4ef3-8e02-9c335eb23204",
  "locationName": "Sample ice cream shop",
  "rating": 5,
  "userNotes": "I love the subtle notes of orange in this ice cream!"
}
'''

def validate_input(value, input_type: str) -> bool:
    if input_type.lower() == 'user':
        validation_url = f'https://serverlessohapi.azurewebsites.net/api/GetUser?userId={value}'
        logging.info(f'Validating user {value}')
    elif input_type == 'product':
        validation_url = f'https://serverlessohapi.azurewebsites.net/api/GetProduct?productId={value}'
        logging.info(f'Validating product {value}')
    elif input_type == 'rating':
        if type(value) != int:
            logging.info(f'Invalid rating {value}, needs to be an integer')
            return False
        if 0 < value < 6:
            return True
        return False
    else:
        logging.error('Not a known type for validation. Failing function')
        return False

    response = requests.get(validation_url)

    if response.text.startswith('{"'):
        return True

    return False


def generate_payload(userId, productId, rating, timestamp, id, location = None,  notes = None):
    json_payload = {
        'userId': userId,
        'productId': productId,
        'rating': rating,
        'timestamp': timestamp,
        'id': id,
    }
    return json_payload


def create_cosmos_container_useable(DATABASE_ID = os.environ.get("AZURE_COSMOSDB_DATABASE_NAME"), CONTAINER = os.environ.get("AZURE_COSMOSDB_COLLECTION"), CONNECTION_STRING = os.environ.get("AZURE_COSMOSDB_CONNECTION_STRING")):
    '''
    Trying to simplify my main function by abstracting cosmos pieces
    '''
    client = cosmos_client.CosmosClient.from_connection_string(CONNECTION_STRING)
    db = client.get_database_client(DATABASE_ID)
    container = db.get_container_client(CONTAINER)

    return container


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    # product_id = req_body.get('product_id')
    # Get body of POST request
    try:
        req_body = req.get_json()
    except ValueError:
        return func.HttpResponse(
             '{"response": "Expected a POST request."}',
             status_code=400,
             mimetype='application/json'
        )

    userId = req_body.get('userId')
    productId = req_body.get('productId')
    rating = req_body.get('rating')
    
    # Validate
    if not validate_input(userId, "user"):
        return func.HttpResponse(
             '{"response": "userId invalid"}',
             status_code=404,
             mimetype='application/json'
        )

    if not validate_input(productId, "product"):
        return func.HttpResponse(
             '{"response": "productId invalid"}',
             status_code=404,
             mimetype='application/json'
        )

    if not validate_input(rating, "rating"):
         return func.HttpResponse(
             '{"response": "rating invalid"}',
             status_code=400,
             mimetype='application/json'
        )

    id = str(uuid.uuid4())
    timestamp = str(datetime.utcnow())
    my_json = generate_payload(userId, productId, rating, timestamp, id)
    request_json = json.dumps(my_json)

    container = create_cosmos_container_useable()
    container.create_item(body=my_json)

    return func.HttpResponse(
            body=request_json,
            status_code=200,
            mimetype='application/json'
    )
