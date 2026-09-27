#Requires -Version 5.1
param(
  [string]$Region = "us-east-1",
  [string]$EksClusterName = "",
  [string]$GithubRepo = "thesayaksarkar/my-app"
)

$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent

if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
  Write-Error "AWS CLI not found. Install: winget install -e --id Amazon.AWSCLI"
}

if (-not $EksClusterName) {
  Write-Host "Existing EKS clusters in $Region:"
  aws eks list-clusters --region $Region --output table
  $EksClusterName = Read-Host "Enter EKS cluster name"
}

$tfDir = Join-Path $root "infra\terraform"
Push-Location $tfDir
try {
  terraform init -input=false
  terraform apply -auto-approve `
    -var="aws_region=$Region" `
    -var="eks_cluster_name=$EksClusterName" `
    -var="github_repo=$GithubRepo"

  $roleArn = terraform output -raw github_actions_role_arn
  $ecrUrl = terraform output -raw ecr_repository_url
  $repoName = ($ecrUrl -split "/")[-1]

  Write-Host "`nConfigure GitHub (run from repo root with gh CLI):"
  Write-Host "  gh variable set AWS_REGION -b `"$Region`" -R $GithubRepo"
  Write-Host "  gh variable set ECR_REPOSITORY -b `"$repoName`" -R $GithubRepo"
  Write-Host "  gh variable set EKS_CLUSTER_NAME -b `"$EksClusterName`" -R $GithubRepo"
  Write-Host "  gh secret set AWS_ROLE_ARN -b `"$roleArn`" -R $GithubRepo"
}
finally {
  Pop-Location
}
