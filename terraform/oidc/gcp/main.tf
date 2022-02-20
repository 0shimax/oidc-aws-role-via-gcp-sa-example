data "tls_certificate" "gcp" {
  url = "https://accounts.google.com/.well-known/openid-configuration"
}

resource "aws_iam_openid_connect_provider" "gcp_oidc" {
  url             = "https://${local.gcp.idp}"
  thumbprint_list = [data.tls_certificate.gcp.certificates[0].sha1_fingerprint]
  client_id_list  = [local.gcp.client_id, local.gcp.client_id_aws]
}

data "aws_iam_policy_document" "gcp_policy_document" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${local.gcp.idp}:email"
      values   = ["${local.gcp.sa}"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.gcp_oidc.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "gcp_role" {
  assume_role_policy   = data.aws_iam_policy_document.gcp_policy_document.json
  name                 = local.gcp.role_name
  max_session_duration = local.gcp.max_session_duration
}

data "aws_iam_policy_document" "gcp_policy_attach_document" {
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

resource "aws_iam_policy" "gcp_policy" {
  name   = local.gcp.policy_name
  policy = data.aws_iam_policy_document.gcp_policy_attach_document.json
}

resource "aws_iam_role_policy_attachment" "gcp_role_pol_attachment" {
  role       = aws_iam_role.gcp_role.name
  policy_arn = aws_iam_policy.gcp_policy.arn
}
