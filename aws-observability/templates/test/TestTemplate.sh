#!/bin/sh

echo "Testing for Master Template....................."

export AWS_REGION=$1
export AWS_PROFILE=$2
export TEMPLATE_S3_BUCKET="cf-templates-1qpf3unpuo1hw-ap-south-1"
# App to test
export AppName=$3
export InstallType=$4

export uid=`cat /dev/random | LC_CTYPE=C tr -dc "[:lower:]" | head -c 6`

# Sumo Logic Access Configuration
export Section1aSumoLogicDeployment=$5
export Section1bSumoLogicAccessID=$6
export Section1cSumoLogicAccessKey=$7
export Section1dSumoLogicOrganizationId=$8
export Section1eSumoLogicResourceRemoveOnDeleteStack=true

export Section2cAccountAlias=${InstallType}
export Section2dTagAWSResourcesFilterExpression=".*"
export Section6fAutoEnableS3LogsFilterExpression=".*"
export Section8dAutoSubscribeLambdaLogGroupPattern=".*"

export Section2aTagAWSResourcesOptions="None"
export Section2bAWSResourcesList=""
export Section3aInstallObservabilityApps="No"
export Section4aEC2CreateMetaDataSource="No"
export Section5aCreateMetricsSourcesOptions="None"
export Section6aALBCreateLogSource="No"
export Section6eAutoEnableS3LogsALBResourcesOptions="None"
export Section7aCreateCloudTrailLogSource="No"
export Section8aLambdaCreateCloudWatchLogsSource="No"
export Section8cAutoSubscribeLogGroupsLambdaOptions="None"


# By Default, we create explorer view, Metric Rules and FER, as we need them for each case.
# Stack Name
export stackName="${AppName}-${InstallType}"

# onlyapps - Installs only the apps in Sumo Logic.
if [[ "${InstallType}" == "onlyapps" ]]
then
    export Section3aInstallObservabilityApps="Yes"
elif [[ "${InstallType}" == "onlytaggingexisting" ]]
then
    export Section2aTagAWSResourcesOptions="Existing"
    export Section2bAWSResourcesList="alb, dynamodb, apigateway"
# onlytagging - Tags only the new resources. rds, lambda, ec2
elif [[ "${InstallType}" == "onlytaggingnew" ]]
then
    export Section2aTagAWSResourcesOptions="New"
    export Section2bAWSResourcesList="ec2, rds, lambda"
# onlytagging - Tags both existing and the new resources. all.
elif [[ "${InstallType}" == "onlytagging" ]]
then
    export Section2aTagAWSResourcesOptions="Both"
    export Section2bAWSResourcesList="ec2, alb, dynamodb, apigateway, rds, lambda"
# onlys3autoenableexisting - Enable S3 logging for existing ALB. Needs an existing bucket or takes if new bucket is created otherwise stack creation fails.
elif [[ "${InstallType}" == "onlys3autoenableexisting" ]]
then
    export Section6eAutoEnableS3LogsALBResourcesOptions="Existing"
    export Section6bALBS3LogsBucketName="sumologiclambdahelper-${AWS_REGION}"
# onlys3autoenablenew - Enable S3 logging for new ALB. Needs an existing bucket or takes if new bucket is created otherwise stack creation fails.
elif [[ "${InstallType}" == "onlys3autoenablenew" ]]
then
    export Section6eAutoEnableS3LogsALBResourcesOptions="New"
    export Section6bALBS3LogsBucketName="sumologiclambdahelper-${AWS_REGION}"
# onlys3autoenable - Enable S3 logging for both ALB. Needs an existing bucket or takes if new bucket is created otherwise stack creation fails.
elif [[ "${InstallType}" == "onlys3autoenable" ]]
then
    export Section6eAutoEnableS3LogsALBResourcesOptions="Both"
    export Section6bALBS3LogsBucketName="sumologiclambdahelper-${AWS_REGION}"
# onlyec2source - Only Creates the EC2 metadata Source.
elif [[ "${InstallType}" == "onlyec2source" ]]
then
    export Section4aEC2CreateMetaDataSource="Yes"
# onlymetricssourceemptyname - Only Creates the CloudWatch Metrics Source with "" EMPTY namespaces.
elif [[ "${InstallType}" == "onlymetricssourceemptyname" ]]
then
    export Section5aCreateMetricsSourcesOptions="CloudWatchMetrics"
    export Section5bMetricsNameSpaces=""
# onlymetricssourcewithname - Only Creates the CloudWatch Metrics Source with namespaces AWS/ApplicationELB, AWS/ApiGateway, AWS/DynamoDB, AWS/Lambda, AWS/RDS.
elif [[ "${InstallType}" == "onlymetricssourcewithname" ]]
then
    export Section5aCreateMetricsSourcesOptions="CloudWatchMetrics"
    export Section5bMetricsNameSpaces="AWS/EC2, AWS/ApplicationELB, AWS/ApiGateway, AWS/DynamoDB, AWS/Lambda, AWS/RDS, AWS/EBS, AWS/ECS, AWS/ElastiCache, AWS/ELB, AWS/NetworkELB, AWS/Redshift, AWS/Kinesis, AWS/AutoScaling"
# onlyanomalywithname - Only Creates the Anamoly Source with namespaces AWS/ApplicationELB, AWS/ApiGateway, AWS/DynamoDB, AWS/Lambda, AWS/RDS.
elif [[ "${InstallType}" == "onlyanomalywithname" ]]
then
    export Section5aCreateMetricsSourcesOptions="InventorySource"
    export Section5bMetricsNameSpaces="AWS/EC2, AWS/ApplicationELB, AWS/ApiGateway, AWS/DynamoDB, AWS/Lambda, AWS/RDS, AWS/EBS, AWS/ECS, AWS/ElastiCache, AWS/ELB, AWS/NetworkELB, AWS/Redshift, AWS/Kinesis, AWS/AutoScaling"
# onlycloudtrailwithbucket - Only Creates the CloudTrail Logs Source with new Bucket.
elif [[ "${InstallType}" == "onlycloudtrailwithbucket" ]]
then
    export Section7aCreateCloudTrailLogSource="Yes"
# onlycloudtrailexisbucket - Only Creates the CloudTrail Logs Source with existing Bucket. If no "" empty bucket provided with empty bucket name, it fails.
elif [[ "${InstallType}" == "onlycloudtrailexisbucket" ]]
then
    export Section7aCreateCloudTrailLogSource="Yes"
    export Section7cCloudTrailBucketPathExpression="AWSLogs/Sourabh/Test"
    export Section7bCloudTrailLogsBucketName="sumologiclambdahelper-${AWS_REGION}"
# updatecloudtrailsource - Only updates the CloudTrail Logs Source with if Collector name and source name is provided.
elif [[ "${InstallType}" == "updatecloudtrailsource" ]]
then
    export Section7dCloudTrailLogsSourceUrl="https://api.sumologic.com/api/v1/collectors/171619902/sources/793849844"
# cwlogssourceonly - Creates a Cloudwatch logs source, with lambda function of log group connector.
elif [[ "${InstallType}" == "cwlogssourceonly" ]]
then
    export Section8aLambdaCreateCloudWatchLogsSource="Yes"
# cwlogssourcenewlambdaautosub - Creates a Cloudwatch logs source, with lambda function of log group connector with auto subscribe only for new lambda.
elif [[ "${InstallType}" == "cwlogssourcenewlambdaautosub" ]]
then
    export Section8aLambdaCreateCloudWatchLogsSource="Yes"
    export Section8cAutoSubscribeLogGroupsLambdaOptions="New"
# cwlogssourceexitlambdaautosub - Creates a Cloudwatch logs source, with lambda function of log group connector WITHOUT auto subscribe only for new lambda.
elif [[ "${InstallType}" == "cwlogssourceexitlambdaautosub" ]]
then
    export Section8aLambdaCreateCloudWatchLogsSource="Yes"
    export Section8cAutoSubscribeLogGroupsLambdaOptions="Existing"
# cwlogssourcebothlambdaautosub - Creates a Cloudwatch logs source, with lambda function of log group connector WITH auto subscribe only for new and existing lambda.
elif [[ "${InstallType}" == "cwlogssourcebothlambdaautosub" ]]
then
    export Section8aLambdaCreateCloudWatchLogsSources="Yes"
    export Section8cAutoSubscribeLogGroupsLambdaOptions="Both"
    export Section8dAutoSubscribeLambdaLogGroupPattern="lambda"
# cwlogssourcebothlambdaautosub - update the cloudwatch source if collector name and source name is provided.
elif [[ "${InstallType}" == "updatecwlogssource" ]]
then
    export Section8bLambdaCloudWatchLogsSourceUrl=""
# albsourcewithbukcetwithauto - Creates only ALB source with new bucket along with auto subscribe.
elif [[ "${InstallType}" == "albsourcewithbukcetwithauto" ]]
then
    export Section6aALBCreateLogSource="Yes"
    export Section6eAutoEnableS3LogsALBResourcesOptions="Both"
# albsourceexistingbukcet - Creates only ALB source with new existing bucket.
elif [[ "${InstallType}" == "albsourceexistingbukcet" ]]
then
    export Section6aALBCreateLogSource="Yes"
    export Section6bALBS3LogsBucketName="sumologiclambdahelper-${AWS_REGION}"
    export Section6cALBS3BucketPathExpression="Labs/ALB/sourabh"
# updatealbsource - updates only ALB source with provided collector and source.
elif [[ "${InstallType}" == "updatealbsource" ]]
then
    export Section6dALBLogsSourceUrl="aws-observability-collector"
# onlysources - creates all sources with common bucket creation for ALB and CloudTrail with auto enable option.
elif [[ "${InstallType}" == "onlysources" ]]
then
    export Section4aEC2CreateMetaDataSource="Yes"
    export Section5aCreateMetricsSourcesOptions="Both"
    export Section6aALBCreateLogSource="Yes"
    export Section7aCreateCloudTrailLogSource="Yes"
    export Section8aLambdaCreateCloudWatchLogsSource="Yes"
    export Section6eAutoEnableS3LogsALBResourcesOptions="Existing"
# albexistingcloudtrialnew - creates ALB source with existing bucket and CloudTrail with new bucket. Create CW metrics source also.
elif [[ "${InstallType}" == "albexistingcloudtrialnew" ]]
then
    export Section5aCreateMetricsSourcesOptions="CloudWatchMetrics"
    export Section5bMetricsNameSpaces="AWS/ApplicationELB, AWS/ApiGateway"
    export Section6aALBCreateLogSource="Yes"
    export Section6bALBS3LogsBucketName="sumologiclambdahelper-${AWS_REGION}"
    export Section6cALBS3BucketPathExpression="Labs/ALB/asasdas"
    export Section7aCreateCloudTrailLogSource="Yes"
# albnewcloudtrialexisting - creates ALB source with new bucket and CloudTrail with Existing bucket. Create EC2 source also.
elif [[ "${InstallType}" == "albnewcloudtrialexisting" ]]
then
    export Section4aEC2CreateMetaDataSource="Yes"
    export Section6aALBCreateLogSource="Yes"
    export Section7aCreateCloudTrailLogSource="Yes"
    export Section7cCloudTrailBucketPathExpression="AWSLogs/Sourabh/Test"
    export Section7bCloudTrailLogsBucketName="sumologiclambdahelper-${AWS_REGION}"
# albec2apiappall - creates everything for EC2, ALB and API Gateway apps.
elif [[ "${InstallType}" == "albec2apiappall" ]]
then
    export Section3aInstallObservabilityApps="Yes"
    export Section2aTagAWSResourcesOptions="Both"
    export Section2bAWSResourcesList="ec2, alb, apigateway"
    export Section6eAutoEnableS3LogsALBResourcesOptions="Both"
    export Section4aEC2CreateMetaDataSource="Yes"
    export Section5aCreateMetricsSourcesOptions="CloudWatchMetrics"
    export Section5bMetricsNameSpaces="AWS/ApplicationELB, AWS/ApiGateway"
    export Section6aALBCreateLogSource="Yes"
    export Section7aCreateCloudTrailLogSource="Yes"
# rdsdynamolambdaappall - creates everything for RDS, DYNAMO DB and LAMBDA apps.
elif [[ "${InstallType}" == "rdsdynamolambdaappall" ]]
then
    export Section3aInstallObservabilityApps="Yes"
    export Section2aTagAWSResourcesOptions="Both"
    export Section2bAWSResourcesList="dynamodb, rds, lambda"
    export Section8cAutoSubscribeLogGroupsLambdaOptions="Both"
    export Section8dAutoSubscribeLambdaLogGroupPattern="lambda"
    export Section5aCreateMetricsSourcesOptions="InventorySource"
    export Section5bMetricsNameSpaces="AWS/DynamoDB, AWS/Lambda, AWS/RDS"
    export Section7aCreateCloudTrailLogSource="Yes"
    export Section8aLambdaCreateCloudWatchLogsSource="Yes"
# onlyappswithexistingsources - Install Apps with existing sources. This should Update the CloudTrail, CloudWatch and ALB sources.
elif [[ "${InstallType}" == "onlyappswithexistingsources" ]]
then
    export Section3aInstallObservabilityApps="Yes"
    export Section2aTagAWSResourcesOptions="Both"
    export Section2bAWSResourcesList="ec2, alb, apigateway, dynamodb, rds, lambda"
    export Section6eAutoEnableS3LogsALBResourcesOptions="Both"
    export Section6bALBS3LogsBucketName="sumologiclambdahelper-${AWS_REGION}"
    export Section8cAutoSubscribeLogGroupsLambdaOptions="Both"
    export Section8dAutoSubscribeLambdaLogGroupPattern="lambda"
    export Section6dALBLogsSourceUrl="aws-observability-collector"
    export Section7dCloudTrailLogsSourceUrl="defaultparameters-aws-observability-alb-${AWS_REGION}"
    export Section8bLambdaCloudWatchLogsSourceUrl="aws-observability-collector"
# defaultparameters - Install CF with default parameters.
elif [[ "${InstallType}" == "defaultparameters" ]]
then
    echo "Doing Default Installation .............................."
    aws cloudformation deploy --profile ${AWS_PROFILE} --template-file ./templates/sumologic_observability.master.template.yaml --region ${AWS_REGION} \
    --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND --stack-name ${stackName} \
    --parameter-overrides Section1aSumoLogicDeployment="${Section1aSumoLogicDeployment}" Section1bSumoLogicAccessID="${Section1bSumoLogicAccessID}" \
    Section1cSumoLogicAccessKey="${Section1cSumoLogicAccessKey}" Section1dSumoLogicOrganizationId="${Section1dSumoLogicOrganizationId}" \
    Section1eSumoLogicResourceRemoveOnDeleteStack="${Section1eSumoLogicResourceRemoveOnDeleteStack}" Section2cAccountAlias="${Section2cAccountAlias}"
else
    echo "No Valid Choice."
fi

if [[ "${InstallType}" != "defaultparameters" ]]
then
    aws cloudformation deploy --profile ${AWS_PROFILE} --template-file ./templates/sumologic_observability.master.template.yaml --region ${AWS_REGION} \
    --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND --stack-name ${stackName} \
    --parameter-overrides Section1aSumoLogicDeployment="${Section1aSumoLogicDeployment}" Section1bSumoLogicAccessID="${Section1bSumoLogicAccessID}" \
    Section1cSumoLogicAccessKey="${Section1cSumoLogicAccessKey}" Section1dSumoLogicOrganizationId="${Section1dSumoLogicOrganizationId}" \
    Section1eSumoLogicResourceRemoveOnDeleteStack="${Section1eSumoLogicResourceRemoveOnDeleteStack}" Section2cAccountAlias="${Section2cAccountAlias}" \
    Section2dTagAWSResourcesFilterExpression="${Section2dTagAWSResourcesFilterExpression}" Section2aTagAWSResourcesOptions="${Section2aTagAWSResourcesOptions}" \
    Section2bAWSResourcesList="${Section2bAWSResourcesList}" Section3aInstallObservabilityApps="${Section3aInstallObservabilityApps}" \
    Section4aEC2CreateMetaDataSource="${Section4aEC2CreateMetaDataSource}" Section5aCreateMetricsSourcesOptions="${Section5aCreateMetricsSourcesOptions}" \
    Section5bMetricsNameSpaces="${Section5bMetricsNameSpaces}" Section6aALBCreateLogSource="${Section6aALBCreateLogSource}" Section6bALBS3LogsBucketName="${Section6bALBS3LogsBucketName}" \
    Section6cALBS3BucketPathExpression="${Section6cALBS3BucketPathExpression}" Section6dALBLogsSourceUrl="${Section6dALBLogsSourceUrl}" Section6eAutoEnableS3LogsALBResourcesOptions="${Section6eAutoEnableS3LogsALBResourcesOptions}" \
    Section6fAutoEnableS3LogsFilterExpression="${Section6fAutoEnableS3LogsFilterExpression}" Section7aCreateCloudTrailLogSource="${Section7aCreateCloudTrailLogSource}" \
    Section7bCloudTrailLogsBucketName="${Section7bCloudTrailLogsBucketName}" Section7cCloudTrailBucketPathExpression="${Section7cCloudTrailBucketPathExpression}" \
    Section7dCloudTrailLogsSourceUrl="${Section7dCloudTrailLogsSourceUrl}" Section8aLambdaCreateCloudWatchLogsSource="${Section8aLambdaCreateCloudWatchLogsSource}" \
    Section8bLambdaCloudWatchLogsSourceUrl="${Section8bLambdaCloudWatchLogsSourceUrl}" Section8cAutoSubscribeLogGroupsLambdaOptions="${Section8cAutoSubscribeLogGroupsLambdaOptions}" \
    Section8dAutoSubscribeLambdaLogGroupPattern="${Section8dAutoSubscribeLambdaLogGroupPattern}"
fi