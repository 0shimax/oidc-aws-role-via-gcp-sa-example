#!/bin/bash
set -eu -o pipefail

GCLOUD_CONFIGURATION={your GCP Service Account Name. i.e. The @ prefix of email.}
GSA_EMAIL={your GCP Service Account Emal to impute AWS IAM Role}
AWS_ACCOUNT={your AWS account id}
AWS_ROLE_NAME={your AWS IAM Role name to be imputed}

GCLOUD="gcloud"
GCLOUD_ACCOUNT=$(${GCLOUD} config get-value account)
GSA_UID=$(${GCLOUD} iam service-accounts describe ${GSA_EMAIL} --format="value(uniqueId)")
GSA_ID_TOKEN=$(${GCLOUD} --impersonate-service-account=${GSA_EMAIL} auth print-identity-token --audiences=${GSA_UID} --include-email)

AWS_ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT}:role/${AWS_ROLE_NAME}"
AWS_ROLE_SESSION_NAME="gsa-oidc-${GCLOUD_CONFIGURATION}"

aws \
  --profile gsa-oidc \
  sts assume-role-with-web-identity \
  --role-arn "${AWS_ROLE_ARN}" \
  --role-session-name "${AWS_ROLE_SESSION_NAME}" \
  --web-identity-token "${GSA_ID_TOKEN}" \
    | jq "{Version: 1} + .Credentials"