from typing import List
import logging

import json
import uuid
import azure.functions as func


def main(event: func.EventHubEvent, doc: func.Out[func.Document]):
    message = event.get_body().decode("utf-8")
    logging.info("Python EventHub trigger processed an event: %s", message)
    sale_events = json.loads(message)
    logging.info("Event Count: %s", len(sale_events))
    for sale_event in sale_events:
        # load to cosmosdb

        newdoc = sale_event
        newdoc["id"] = str(uuid.uuid4())
        newdoc["partition"] = sale_event["header"]["locationName"][:1]

        output = json.dumps(newdoc)
        # Use a data service to store the ratings information to the backend
        doc.set(func.Document.from_json(output))

        # total number of items purchased
        # total cost of items purchased
        # sales number
        # sales date time
        # store location
        # URL for the receipt
