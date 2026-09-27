#Requires -Version 5.1
param(
  [string]$Image = "",
  [string]$RepoRoot = ""
)

$ErrorActionPreference = "Stop"
if (-not $RepoRoot) {
  $RepoRoot = Split-Path $PSScriptRoot -Parent
}

Set-Location $RepoRoot

if (-not $Image) {
  $Image = Read-Host "ECR image URI (account.dkr.ecr.region.amazonaws.com/my-app:tag) or local tag e.g. my-app:local"
}

if ($Image -match "\.dkr\.ecr\.") {
  if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
    Write-Error "AWS CLI required to login to ECR"
  }
  $region = ($Image -split "\.")[3]
  aws ecr get-login-password --region $region | docker login --username AWS --password-stdin (($Image -split "/")[0])
  docker pull $Image
}

kubectl apply -f deployment.yaml -f service.yaml
kubectl set image deployment/my-app my-app=$Image
kubectl rollout status deployment/my-app --timeout=5m
kubectl get pods -l app=my-app
Write-Host "Port-forward: kubectl port-forward service/my-app 3000:3000"
