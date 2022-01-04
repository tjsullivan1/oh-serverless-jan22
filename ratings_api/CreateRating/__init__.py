import logging
import requests

import azure.functions as func

'''
Requirements
Validate both userId and productId by calling the existing API endpoints. You can find a user id to test with from the sample payload above
Add a property called id with a GUID value
Add a property called timestamp with the current UTC date time
Validate that the rating field is an integer from 0 to 5
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
def validate_http_success(resp_status_code: int) -> bool:
    if 200 <= resp_status_code <= 226:
        logging.info(f'Request was sucessful, status was {resp_status_code} - this indicates the object existed')
        return True
    elif 300 <= resp_status_code <= 308:
        logging.info(f'Request was redirected, status was {resp_status_code}')
        return False
    elif 400 <= resp_status_code <= 499:
        logging.error(f'Request was an client error, status was {resp_status_code}')
    elif 500 <= resp_status_code <= 599:
        logging.error(f'Request was an server error, status was {resp_status_code}')

    return False


def validate_input(value, input_type: str):
    if input_type.lower() == 'user':
        validation_url = f'https://serverlessohapi.azurewebsites.net/api/GetUser?userId={value}'
        logging.info(f'Validating user {value}')
    elif input_type == 'product':
        validation_url = f'https://serverlessohapi.azurewebsites.net/api/GetProduct?productId={value}'
        logging.info(f'Validating product {value}')
    elif input_type == 'rating':
        return False
    else:
        logging.error('Not a known type for validation. Failing function')
        return False

    validation_resp = requests.get(validation_url)
    if validate_http_success(validation_resp.status_code):
        logging.info(f'Validated value {value}')
        return 'Valid'
    elif validation_resp.status_code == 400:
        logging.info(f'Value is invalid, {value}')
        return 'Not Valid'

    return False


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    # product_id = req_body.get('product_id')
    # Get body of POST request
    try:
        req_body = req.get_json()
    except ValueError:
        return func.HttpResponse(
             "Expected a POST request.",
             status_code=400
        )

    userId = req_body.get('userId')
    productId = req_body.get('productId')
    rating = req_body.get('rating')
    
    if userId and productId and rating:
        
        if validate_input(userId, 'User') == 'Valid':
            logging.info(f'User ID {userId} was valid')
            if validate_input(productId, 'product') == 'Valid':
                logging.info(f'Product ID {productId} was valid')
                return func.HttpResponse(f"The product name for your product id {userId} is Starfruit Explosion")
        else:
            return func.HttpResponse(f"The user id, {userId}, inputted was invalid", status_code=400)
    else:
        return func.HttpResponse(
             "This HTTP triggered function executed successfully. Pass a product_id in the query string or in the request body for a personalized response.",
             status_code=200
        )
