import logging
import os

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


def lambda_handler(event, context):
    logger.info("Running lambda handler")
    logger.info(event)

    token = get_auth_token()

    conn = get_connection(token)

    cur = conn.cursor()
    cur.execute("""SELECT now()""")
    query_results = cur.fetchall()
    print(query_results)

    return None


if __name__ == "__main__":
    lambda_handler({}, {})
