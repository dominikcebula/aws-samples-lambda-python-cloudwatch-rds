# aws-samples-lambda-python-cloudwatch-rds

# AWS Sample - Custom Metrics using Lambda in Python

## Overview

This repository contains sample code that implements AWS CloudWatch Custom Metrics using Lambda in Python.

## Big picture

Lambda code queries database periodically using SQL Queries and generates custom metrics based on it. Lambda is executed
based on CloudWatch Event Scheduler, which produces an event used to execute lambda at a fixed rate. Metrics are
produced to a custom namespace, which are then used by CloudWatch Dashboards and CloudWatch Alerts.

![Diagram](docs/diagram.drawio.png)

## Deployment

You will need to have the following tools installed

* Python 3.x
* PIP
* Terraform
* psql - PostgreSQL Client
* AWS CLI with `.aws/credentials` setup

Having the above tools, you need to execute `terrafrom apply` to deploy:

* Lambda
* CloudWatch Event Scheduler
* CloudWatch Dashboard
* Database
* Database Schema and Sample Data

## Author

Dominik Cebula

* https://dominikcebula.com/
* https://blog.dominikcebula.com/
* https://www.udemy.com/user/dominik-cebula/
