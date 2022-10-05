locals {
  eks_name = {
    value = "${local.resource_prefix.value}-eks"
  }
}

data aws_iam_policy_document "iam_policy_eks" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource aws_iam_role "iam_for_eks" {
  name               = "${local.resource_prefix.value}-iam-for-eks"
  assume_role_policy = data.aws_iam_policy_document.iam_policy_eks.json
  tags = merge({
    Name        = "${local.resource_prefix.value}-og"
    Environment = local.resource_prefix.value
    },{
    git_commit           = "N/A"
    git_file             = "terraform/aws/eks.tf"
    git_org              = "zscaler-bd-sa"
    git_repo             = "zs-terraform-iac-scanning"
    })
}

resource aws_iam_role_policy_attachment "policy_attachment-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.iam_for_eks.name
}

resource aws_iam_role_policy_attachment "policy_attachment-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.iam_for_eks.name
}

resource aws_vpc "eks_vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge({
    Name = "${local.resource_prefix.value}-eks-vpc"
    },{
    git_commit           = "N/A"
    git_file             = "terraform/aws/eks.tf"
    git_org              = "zscaler-bd-sa"
    git_repo             = "zs-terraform-iac-scanning"
    })
}

resource aws_subnet "eks_subnet1" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.10.10.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = merge({
    Name                                            = "${local.resource_prefix.value}-eks-subnet"
    "kubernetes.io/cluster/${local.eks_name.value}" = "shared"
    },{
    git_commit           = "N/A"
    git_file             = "terraform/aws/eks.tf"
    git_org              = "zscaler-bd-sa"
    git_repo             = "zs-terraform-iac-scanning"
    }, {
    "kubernetes.io/cluster/$$${local.eks_name.value}" = "shared"
    "kubernetes.io/cluster/$${local.eks_name.value}"  = "shared"
    }, {
    "kubernetes.io/cluster/$$$${local.eks_name.value}" = "shared"
    "kubernetes.io/cluster/$$${local.eks_name.value}"  = "shared"
    "kubernetes.io/cluster/$${local.eks_name.value}"   = "shared"
  })
}

resource aws_subnet "eks_subnet2" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.10.11.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true
  tags = merge({
    Name                                            = "${local.resource_prefix.value}-eks-subnet2"
    "kubernetes.io/cluster/${local.eks_name.value}" = "shared"
    },{
    git_commit           = "N/A"
    git_file             = "terraform/aws/eks.tf"
    git_org              = "zscaler-bd-sa"
    git_repo             = "zs-terraform-iac-scanning"
    },{
    "kubernetes.io/cluster/$$${local.eks_name.value}" = "shared"
    "kubernetes.io/cluster/$${local.eks_name.value}"  = "shared"
    },{
    "kubernetes.io/cluster/$$$${local.eks_name.value}" = "shared"
    "kubernetes.io/cluster/$$${local.eks_name.value}"  = "shared"
    "kubernetes.io/cluster/$${local.eks_name.value}"   = "shared"
})
}

resource aws_eks_cluster "eks_cluster" {
  name     = local.eks_name.value
  role_arn = "${aws_iam_role.iam_for_eks.arn}"

  vpc_config {
    endpoint_private_access = true
    subnet_ids              = ["${aws_subnet.eks_subnet1.id}", "${aws_subnet.eks_subnet2.id}"]
  }

  depends_on = [
    aws_iam_role_policy_attachment.policy_attachment-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.policy_attachment-AmazonEKSServicePolicy,
  ]
  tags = merge({
    Name        = "${local.resource_prefix.value}-og"
    Environment = local.resource_prefix.value
    },{
    git_commit           = "N/A"
    git_file             = "terraform/aws/eks.tf"
    git_org              = "zscaler-bd-sa"
    git_repo             = "zs-terraform-iac-scanning"
    })
}

output "endpoint" {
  value = "${aws_eks_cluster.eks_cluster.endpoint}"
}

output "kubeconfig-certificate-authority-data" {
  value = "${aws_eks_cluster.eks_cluster.certificate_authority.0.data}"
}