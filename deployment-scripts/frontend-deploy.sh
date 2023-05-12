CWD=$(pwd)

source $CWD/deployment-scripts/frontend-variables.sh

PKG_NAME=$(cat ${DIRECTORY}/package.json | jq -r '.name')

cd ${DIRECTORY}

NODE_ENV=production
NAME=$(echo $PKG_NAME | sed 's/\(.*\)-app-client/\1/g')

npm run build

aws s3 sync --delete --acl=private "build/" \
  s3://$(aws ssm get-parameter --name "/${SERVICE}/${BUILD_STAGE}/${FRONTEND_NAME}/s3_site" | jq -r .Parameter.Value)/

aws cloudfront create-invalidation --paths '/*' --distribution-id \
  $(aws ssm get-parameter --name "/${SERVICE}/${BUILD_STAGE}/${FRONTEND_NAME}/distribution_id" | jq -r .Parameter.Value)