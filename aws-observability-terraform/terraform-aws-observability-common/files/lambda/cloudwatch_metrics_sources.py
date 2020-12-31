import logging
import os
import cfnresponse

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)
# Update the Default value whenever CF starts supporting More Namespaces
default = ["AWS/ApplicationELB", "AWS/ApiGateway", "AWS/DynamoDB", "AWS/Lambda", "AWS/RDS", "AWS/ECS",
           "AWS/ElastiCache", "AWS/ELB", "AWS/NetworkELB"]


def lambda_handler(event, context):
    unique_namespaces = set(["AWS/AutoScaling"])
    response_value = {}
    for value in default:
        response_value[value.split("/")[1]] = 'No'

    namespaces = os.environ['CloudWatchMetricsNameSpaces']
    LOGGER.info('Inside the Handler with namespaces as {}'.format(namespaces))
    if namespaces:
        namespace_list = namespaces.split(",")
        for namespace in namespace_list:
            unique_namespaces.add(namespace.replace(" ", ""))
            response_value[namespace.split("/")[1]] = "Yes"

    response_value["namespaces"] = ", ".join(unique_namespaces)
    LOGGER.info("Response is {}".format(response_value))
    cfnresponse.send(event, context, cfnresponse.SUCCESS, response_value, "NamespaceSplitting")
