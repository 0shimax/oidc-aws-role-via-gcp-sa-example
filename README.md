# Preparation
Confirm clientId of GCP SA

```
gcloud iam service-accounts describe aws-user@{{ google_project_id }}.iam.gserviceaccount.com --format=json
```

Check the `"uniqueId": "xxxxxx"` field. It's clientId.
Then, define terraform files.

# Impute to AWS IAM Role

## Change your SA on GCP

```
gcloud config set account {your GCP SA}
```

## AWS auth login (Impute GCP SA to the AWS IAM role)

```
aws --profile gsa-aws-user sts get-caller-identity | jq -r .Arn
```

## Set AWS credentials to environment variables

```
./source set_aws_temp_credential.sh
```

# Others
Define and run `terraform/oidc/github_actions` if you want to use OIDC in Github Actoins.