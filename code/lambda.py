import logging

logger = logging.getLogger()
logger.setLevel("INFO")

logger.info("Loading lambda function")


def lambda_handler(event, context):
    logger.info("Running lambda handler")
    logger.info(event)

    return None
