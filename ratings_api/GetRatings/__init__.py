import logging

import os
import azure.functions as func

from azure.cosmos import CosmosClient

import json


def create_cosmos_container_useable(
    DATABASE_ID=os.environ.get("AZURE_COSMOSDB_DATABASE_NAME"),
    CONTAINER=os.environ.get("AZURE_COSMOSDB_COLLECTION"),
    CONNECTION_STRING=os.environ.get("AZURE_COSMOSDB_CONNECTION_STRING"),
):
    """
    Trying to simplify my main function by abstracting cosmos pieces
    """
    client = CosmosClient.from_connection_string(CONNECTION_STRING)
    db = client.get_database_client(DATABASE_ID)
    container = db.get_container_client(CONTAINER)

    return container


def query_cosmos_db_by_user(container, userId):
    logging.info(f"querying by user {userId}.")
    user_query = f"SELECT * FROM r WHERE r.userId='{userId}'"
    logging.info(f"query is going to be {user_query}")
    items = list(container.query_items(query=user_query, enable_cross_partition_query=True))

    return items


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Python HTTP trigger function processed a request.")
    logger = logging.getLogger("tjs")
    logger.setLevel(logging.DEBUG)
    sh = logging.StreamHandler()
    sh.setLevel(logging.DEBUG)
    logger.addHandler(sh)
    logger.debug("Hello")

    userId = req.params.get("userId")
    if not userId:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            userId = req_body.get("userId")

    if userId:
        logger.debug(f"User ID is {userId}")
        container = create_cosmos_container_useable()
        q_result = query_cosmos_db_by_user(container, userId)
        logger.debug(f"Results are {q_result}")
        logger.debug(f"Results are of type {type(q_result)}")

        if len(q_result) == 0:
            return func.HttpResponse(
                '{"response": "Found no results, please double check your user ID ."}',
                status_code=404,
                mimetype="application/json",
            )

        result_json = json.dumps(q_result)
        logger.debug(f"Json of results is {result_json}")

        return func.HttpResponse(result_json, status_code=200, mimetype="application/json")
    else:
        return func.HttpResponse(
            '{"response": "Expected a ratingId parameter."}', status_code=400, mimetype="application/json"
        )
