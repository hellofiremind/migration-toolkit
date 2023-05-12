cd $SERVICE_NAME

deployDocker() { 
    FOLDER=$(echo $SERVICE_NAME | cut -d '/' -f 2)
    echo $FOLDER
    export ACCOUNT_ID=$(aws sts get-caller-identity | jq -r ".Account")
    export ECR_URL="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SERVICE}-${BUILD_STAGE}-${FOLDER}"
    
    aws ecr get-login-password | docker login --username AWS --password-stdin "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

    docker build \
    -t ${ECR_URL}:latest \
    --no-cache -f ./Dockerfile ./

    docker tag ${ECR_URL}:latest ${ECR_URL}:latest
    docker push ${ECR_URL}:latest
}

deployDocker