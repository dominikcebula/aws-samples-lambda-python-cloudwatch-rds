import logging
import os
from pathlib import Path

import boto3
import psycopg2

logger = logging.getLogger()
logger.setLevel("INFO")

logger.info("Loading lambda function")

endpoint_host_name = os.environ['ENDPOINT_HOST_NAME']
port = int(os.environ['PORT'])
db_name = os.environ['DB_NAME']
db_user_name = os.environ['DB_USER_NAME']
aws_region = os.environ['AWS_REGION']


def lambda_handler(event, context):
    logger.info("Running lambda handler...")

    logger.info("Fetching auth token...")
    token = get_auth_token()
    logger.info("Auth token fetched.")

    logger.info("Opening connection to DB...")
    with get_connection(token) as connection:
        logger.info("Connection opened.")

        logger.info("Running sql queries")
        produce_metrics_for_sql_queries(connection)

    logger.info("Lambda handler finished.")


def get_auth_token():
    client = boto3.client('rds')
    token = client.generate_db_auth_token(
        DBHostname=endpoint_host_name,
        Port=port,
        DBUsername=db_user_name,
        Region=aws_region)
    return token


def get_connection(token):
    conn = psycopg2.connect(host=endpoint_host_name,
                            port=port,
                            database=db_name,
                            user=db_user_name,
                            password=token,
                            sslrootcert="SSLCERTIFICATE")
    return conn


def produce_metrics_for_sql_queries(connection):
    produce_metrics_for_sql_query("orders", "sql/orders.sql", connection)
    produce_metrics_for_sql_query("payments", "sql/payments.sql", connection)
    produce_metrics_for_sql_query("products", "sql/products.sql", connection)


def produce_metrics_for_sql_query(metric_name, sql_file, connection):
    logger.info(f"Producing metric {metric_name}...")
    sql_content = Path(sql_file).read_text()

    with connection.cursor() as cursor:
        cursor.execute(sql_content)
        results = cursor.fetchall()
        print(results)

    logger.info(f"Metric {metric_name} produced.")


if __name__ == "__main__":
    lambda_handler({}, {})
