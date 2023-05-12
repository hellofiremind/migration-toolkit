export AWS_REGION=eu-west-1
export REACT_APP_AWS_REGION=$AWS_REGION

export ACCOUNT_ID=$(aws ssm get-parameter --name "/${SERVICE}/${BUILD_STAGE}/account_id" | jq -r .Parameter.Value)
echo "Deploying to ${BUILD_STAGE} (${ACCOUNT_ID})"

aws sts get-caller-identity
