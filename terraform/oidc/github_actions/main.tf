data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

resource "aws_iam_openid_connect_provider" "github_oidc" {
  url             = "https://${local.github.idp}"
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
  client_id_list  = [local.github.client_id]
}

data "aws_iam_policy_document" "gha_policy_document" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringLike"
      variable = "${local.github.idp}:sub"
      values   = ["repo:${local.github.org}/${local.github.repo}:*"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.github_oidc.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "github_actions_role" {
  assume_role_policy   = data.aws_iam_policy_document.gha_policy_document.json
  name                 = local.github.role_name
  max_session_duration = local.github.max_session_duration
}

data "aws_iam_policy_document" "gha_policy_attach_document" {
  statement {
    actions = [
      # write some actions
      "s3:Get*",
      "s3:Put",
      "codepipeline:*",
    ]
    effect = "Allow"
    # Limit permissions to the resources that the role needs to opelate
    resources = ["*"]
  }
}

resource "aws_iam_policy" "gha_policy" {
  name   = local.github.policy_name
  policy = data.aws_iam_policy_document.gha_policy_attach_document.json
}

resource "aws_iam_role_policy_attachment" "gha_role_pol_attachment" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.gha_policy.arn
}
