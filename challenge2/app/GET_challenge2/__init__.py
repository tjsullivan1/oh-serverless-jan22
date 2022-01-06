import logging

import azure.functions as func


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Python HTTP trigger function processed a request.")

    product_id = req.params.get("product_id")
    if not product_id:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            product_id = req_body.get("product_id")

    if product_id:
        return func.HttpResponse(f"The product name for your product id {product_id} is Starfruit Explosion")
    else:
        return func.HttpResponse(
            "This HTTP triggered function executed successfully. Pass a product_id in the query string or in the request body for a personalized response.",
            status_code=200,
        )
