#TODO
/*AccountCheck:
  Type: Custom::EnterpriseOrTrialAccountCheck
  Properties:
    ServiceToken: !GetAtt LambdaHelper.Arn
    Region: !Ref "AWS::Region"
    SumoAccessID: !Ref SumoLogicAccessID
    SumoAccessKey: !Ref SumoLogicAccessKey
    SumoDeployment: !Ref SumoLogicDeployment

############# START - RESOURCES FOR METADATA SOURCE #################

SumoLogicMetaDataSource:
  Condition: install_metadata_source
  Type: Custom::AWSSource
  Properties:
    ServiceToken: !GetAtt LambdaHelper.Arn
    Region: !Ref "AWS::Region"
    RemoveOnDeleteStack: !Ref RemoveSumoLogicResourcesOnDeleteStack
    SourceType: AwsMetadata
    SourceName: !Ref MetaDataSourceName
    SourceCategory: "aws/observability/ec2/metadata"
    CollectorId: !GetAtt SumoLogicHostedCollector.COLLECTOR_ID
    SumoAccessID: !Ref SumoLogicAccessID
    SumoAccessKey: !Ref SumoLogicAccessKey
    SumoDeployment: !Ref SumoLogicDeployment
    RoleArn: !GetAtt SumoLogicSourceRole.Arn*/
