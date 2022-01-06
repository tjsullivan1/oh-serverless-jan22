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


def query_cosmos_db_by_rating(container, ratingId):
    logging.info(f"querying by rating {ratingId}.")
    rating_query = f"SELECT * FROM r WHERE r.id='{ratingId}'"
    logging.info(f"query is going to be {rating_query}")
    items = list(container.query_items(query=rating_query, enable_cross_partition_query=True))

    return items


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Python HTTP trigger function processed a request.")
    logger = logging.getLogger("tjs")
    logger.setLevel(logging.DEBUG)
    sh = logging.StreamHandler()
    sh.setLevel(logging.DEBUG)
    logger.addHandler(sh)
    logger.debug("Hello")

    ratingId = req.params.get("ratingId")
    if not ratingId:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            ratingId = req_body.get("ratingId")

    if ratingId:
        logger.debug(f"Rating ID is {ratingId}")
        container = create_cosmos_container_useable()
        q_result = query_cosmos_db_by_rating(container, ratingId)
        if len(q_result) > 1:
            return func.HttpResponse(
                '{"response": "Expected a single item response."}', status_code=422, mimetype="application/json"
            )

        result_json = json.dumps(q_result[0])
        return func.HttpResponse(result_json, status_code=200, mimetype="application/json")
    else:
        return func.HttpResponse(
            '{"response": "Expected a ratingId parameter."}', status_code=400, mimetype="application/json"
        )
