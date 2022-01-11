import datetime
import logging
from azure.storage.common import CloudStorageAccount
from azure.storage.blob import ContainerClient
import os
import uuid
import typing

import pandas as pd
import json
import azure.functions as func
from azure.cosmos import CosmosClient

logger = logging.getLogger("tjs")
logger.setLevel(logging.DEBUG)
sh = logging.StreamHandler()
sh.setLevel(logging.DEBUG)
logger.addHandler(sh)
logger.debug("Hello")


def create_blob_lists(unprocessed_container, account_name) -> list:
    blobs = list(unprocessed_container.list_blobs())
    base_url = "https://{}.blob.core.windows.net/raw/".format(account_name)
    results = map(lambda x: {"Order": x.name[:14], "File": x.name}, blobs)
    df = pd.DataFrame(list(results))
    grouped_results = df.groupby("Order")
    messages = []
    for group in grouped_results:
        if len(group[1].values) == 3:
            group_message = {"Order": group[0]}

            group_message["OrderHeaderDetails"] = base_url + group[1].values[0][1]
            group_message["OrderLineItems"] = base_url + group[1].values[1][1]
            group_message["ProductInformation"] = base_url + group[1].values[2][1]
            messages.append(json.dumps(group_message))

    return messages


def get_blob_contents(
    my_blob, unprocessed_container, processed_container, testing=False
):
    logger.info("working through blobbed str")
    logger.info(type(my_blob))
    logger.info(f"{my_blob}")
    blobs_dict = json.loads(my_blob)
    order_number = blobs_dict.get("Order")
    logger.info(f"Order {order_number}")
    logger.info(f"Blob length is {len(blobs_dict)}")
    header_details_file_name = blobs_dict.get("OrderHeaderDetails").split("/")[4]
    line_items_file_name = blobs_dict.get("OrderLineItems").split("/")[4]
    product_info_file_name = blobs_dict.get("ProductInformation").split("/")[4]

    header_blob = unprocessed_container.get_blob_client(blob=header_details_file_name)
    headers = header_blob.download_blob().readall()
    copy_headers = processed_container.get_blob_client(blob=header_details_file_name)
    copy_headers.start_copy_from_url(header_blob.url)
    header_blob.delete_blob()

    line_items_blob = unprocessed_container.get_blob_client(blob=line_items_file_name)
    line_items = line_items_blob.download_blob().readall()
    copy_line_items = processed_container.get_blob_client(blob=line_items_file_name)
    copy_line_items.start_copy_from_url(line_items_blob.url)
    line_items_blob.delete_blob()

    product_info_blob = unprocessed_container.get_blob_client(
        blob=product_info_file_name
    )
    product_info = product_info_blob.download_blob().readall()
    copy_product_info = processed_container.get_blob_client(blob=product_info_file_name)
    copy_product_info.start_copy_from_url(product_info_blob.url)
    product_info_blob.delete_blob()

    return order_number, headers, line_items, product_info


def generate_payload(order_number, headers, line_items, product_info, timestamp, id):
    json_payload = {
        "order_number": order_number,
        "headers": headers,
        "line_items": line_items,
        "product_info": product_info,
        "timestamp": timestamp,
        "id": id,
    }
    return json_payload


def create_cosmos_container_useable(
    DATABASE_ID=os.environ.get("AZURE_COSMOSDB_DATABASE_NAME"),
    CONTAINER=os.environ.get("AZURE_COSMOSDB_COLLECTION"),
    CONNECTION_STRING=os.environ.get("AZURE_COSMOSDB_CONNECTION_STRING"),
):
    """
    Trying to simplify my main function by abstracting cosmos pieces
    """
    if type(CONNECTION_STRING) == tuple:
        CONNECTION_STRING = CONNECTION_STRING[0]
    client = CosmosClient.from_connection_string(CONNECTION_STRING)
    db = client.get_database_client(DATABASE_ID)
    container = db.get_container_client(CONTAINER)

    return container


def main(mytimer: func.TimerRequest) -> None:
    utc_timestamp = (
        datetime.datetime.utcnow().replace(tzinfo=datetime.timezone.utc).isoformat()
    )

    if mytimer.past_due:
        logging.info("The timer is past due!")

    logging.info("Python timer trigger function ran at %s", utc_timestamp)

    ACCOUNT_NAME = os.environ.get("AZURE_STORAGE_ACCOUNT_NAME")
    AZURE_STORAGE_CONNECTION_STRING = os.environ.get("AZURE_STORAGE_CONNECTION_STRING")
    raw = ContainerClient.from_connection_string(
        conn_str=AZURE_STORAGE_CONNECTION_STRING, container_name="raw"
    )
    processed = ContainerClient.from_connection_string(
        conn_str=AZURE_STORAGE_CONNECTION_STRING, container_name="processed"
    )

    my_blob_lists = create_blob_lists(raw, ACCOUNT_NAME)
    # logger.debug(my_blob_lists)

    for blob in my_blob_lists:
        id = str(uuid.uuid4())
        timestamp = str(datetime.datetime.utcnow())
        order_number, headers, line_items, product_info = get_blob_contents(
            blob, raw, processed
        )

        json_payload = generate_payload(
            order_number,
            str(headers),
            str(line_items),
            str(product_info),
            timestamp,
            id,
        )

        container = create_cosmos_container_useable()
        container.create_item(body=json_payload)
