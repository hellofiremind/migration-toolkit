    export ACCOUNT_ID=$(aws sts get-caller-identity | jq -r ".Account")
    aws ecr get-login-password | docker login --username AWS --password-stdin "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    export ECS_CLUSTER=$(aws ssm get-parameter --name /${TF_SERVICE}/${BUILD_STAGE}/ecs_cluster --region=${AWS_REGION} --query Parameter.Value) 

    temp="${ECS_CLUSTER%\"}"
    CLUSTER_NAME="${temp#\"}"
    echo ${CLUSTER_NAME}
    export ACTIVE=$(aws ecs describe-services --cluster ${CLUSTER_NAME} --services ${TF_SERVICE}-${BUILD_STAGE}-ecs-service-${SERVICE_NAME} | jq --raw-output 'select(.services[].status != null ) | .services[].status') 

    if [ "$ACTIVE" == "ACTIVE" ]; then
        echo "forcing new deployment"
        aws ecs update-service --cluster ${CLUSTER_NAME} --service ${TF_SERVICE}-${BUILD_STAGE}-ecs-service-${SERVICE_NAME}  --force-new-deployment
    fi