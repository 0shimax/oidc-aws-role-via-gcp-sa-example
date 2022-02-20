locals {
  gcp = {
    idp                  = "accounts.google.com"
    client_id            = "xxxxxx"  # <- confirm vai `gcloud iam service-accounts describe` command
    client_id_aws        = "sts.amazonaws.com"
    sa                   = "{GCP SA EMAL}"
    role_name            = "xxxx"
    policy_name          = "xxxx"
    max_session_duration = 1200
  }
}