import datetime
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

    token = get_db_auth_token()
    cloudwatch_client = get_cloudwatch_client()

    try:
        with get_db_connection(token) as connection:
            produce_metrics_for_sql_queries(connection, cloudwatch_client)
    finally:
        cloudwatch_client.close()

    logger.info("Lambda handler finished.")


def get_db_auth_token():
    client = boto3.client('rds')
    token = client.generate_db_auth_token(
        DBHostname=endpoint_host_name,
        Port=port,
        DBUsername=db_user_name,
        Region=aws_region)
    return token


def get_cloudwatch_client():
    return boto3.client('cloudwatch')


def get_db_connection(token):
    conn = psycopg2.connect(host=endpoint_host_name,
                            port=port,
                            database=db_name,
                            user=db_user_name,
                            password=token,
                            sslrootcert="SSLCERTIFICATE")
    return conn


def produce_metrics_for_sql_queries(connection, cloudwatch_client):
    produce_metrics_for_sql_query("orders", "sql/orders.sql", connection, cloudwatch_client)
    produce_metrics_for_sql_query("payments", "sql/payments.sql", connection, cloudwatch_client)
    produce_metrics_for_sql_query("products", "sql/products.sql", connection, cloudwatch_client)


def produce_metrics_for_sql_query(metric_name, sql_file, connection, cloudwatch_client):
    sql_content = Path(sql_file).read_text()

    with connection.cursor() as cursor:
        logger.info(f"Executing query for metrics {metric_name}")
        cursor.execute(sql_content)
        results = cursor.fetchall()
        logger.info(f"Query results for {sql_file}: {results}")

        logger.info(f"Sending metrics for metric {metric_name}")
        put_metrics(cloudwatch_client, metric_name, results)

    logger.info(f"Metric {metric_name} produced.")


def put_metrics(cloudwatch_client, metric_name, results):
    cloudwatch_client_response = cloudwatch_client.put_metric_data(
        Namespace='DB Metrics',
        MetricData=[
            {
                'MetricName': metric_name,
                'Timestamp': datetime.datetime.now(),
                'Unit': 'None',
                'Value': results[0][0]
            },
        ]
    )
    logger.info(f"Cloudwatch client response for {metric_name}: {cloudwatch_client_response}")


if __name__ == "__main__":
    lambda_handler({}, {})
