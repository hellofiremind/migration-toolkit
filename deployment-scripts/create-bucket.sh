export CWD=$(pwd)

# Checks if bucket exists, and calls create bucket function if it doesn't
bucketExists() {
  # Get string returned by head-bucket command "2>&1" lets this also capture errors
  EXIT_STRING=$(aws s3api head-bucket --bucket "${S3_TERRAFORM_STATE_BUCKET}" 2>&1)
  # Gets the return code for the previous head-bucket command
  EXIT_CODE=$?

  # checks if exit string contains a 404, if it does then the bucket doesn't exist
  if $(echo "$EXIT_STRING" | grep 404 >/dev/null) 
  then 
    echo "Bucket does not exist; creating"
    createTerraformBucket && echo Bucket created
    return "$?"
  fi

  if $(echo "$EXIT_STRING" | grep 403 >/dev/null) 
  then 
    echo "$EXIT_STRING"
    echo "This either means the IAM role is not configured correctly, or the bucket name \"${S3_TERRAFORM_STATE_BUCKET}\" is already in use in another account"
    return $EXIT_CODE
  fi

  # If the exit code is 0, it already exists
  if [ $EXIT_CODE -eq 0 ]
  then
    echo "Bucket exists; skipping creation"
  else
    # Outputs the error message the head-bucket command got, and the exit code (most likely 254)
    echo "$EXIT_STRING"
    return $EXIT_CODE
  fi
}

# Creates bucket and adds s3 encryption to it once it is created
createTerraformBucket() {
  aws s3api create-bucket \
    --bucket "${S3_TERRAFORM_STATE_BUCKET}" \
    --region "${S3_TERRAFORM_STATE_REGION}" \
    --create-bucket-configuration LocationConstraint="${S3_TERRAFORM_STATE_REGION}" >/dev/null 2>&1
  echo Waiting for bucket to be created...
  aws s3api wait bucket-exists --bucket "${S3_TERRAFORM_STATE_BUCKET}"
  aws s3api put-bucket-encryption \
    --bucket "${S3_TERRAFORM_STATE_BUCKET}" \
    --server-side-encryption-configuration '{ "Rules": [ { "ApplyServerSideEncryptionByDefault": { "SSEAlgorithm" : "AES256" } } ] }'
  return "$?"
}

bucketExists