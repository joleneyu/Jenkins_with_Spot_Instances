resource "aws_iam_user" "jenkins" {
  name = "EC2-Fleet"

  tags = {
    jenkins_agent_controller = "enable"
  }
}

resource "aws_iam_access_key" "jenkins" {
  user = aws_iam_user.jenkins.name
}

resource "aws_iam_user_policy" "jenkins" {
  name = "jenkins_agent_controller"
  user = aws_iam_user.jenkins.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:*",
        "autoscaling:*",
        "iam:ListInstanceProfiles",
        "iam:ListRoles",
        "iam:PassRole"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}