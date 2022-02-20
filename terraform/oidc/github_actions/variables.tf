locals {
  github = {
    idp                  = "token.actions.githubusercontent.com"
    org                  = "{github org}"
    repo                 = "{github repo name}"
    client_id            = "sts.amazonaws.com"
    role_name            = "xxxxx"
    policy_name          = "xxxxx"
    max_session_duration = 3600
  }
}
