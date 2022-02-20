module "oidc_gha" {
  source = "./oidc/github_actions"
}

module "oidc_gcp" {
  source = "./oidc/gcp"
}