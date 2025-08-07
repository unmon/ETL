# Azure Data Factory Deployment Script
# This script deploys the Azure Data Factory pipeline to read CSV from ADLS and load to SQL
# Updated to use Azure CLI instead of Azure PowerShell modules

param(
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = "rg_unmon_ci",
    
    [Parameter(Mandatory=$false)]
    [string]$SubscriptionId = "c4bc7a9d-0850-490c-b03c-6d2a12c3f7a5",
    
    [Parameter(Mandatory=$false)]
    [string]$ParametersFile = "azuredeploy.parameters.json",
    
    [Parameter(Mandatory=$false)]
    [string]$TemplateFile = "azuredeploy.json"
)

# Check if Azure CLI is installed and authenticated
try {
    $account = az account show 2>$null | ConvertFrom-Json
    if (-not $account) {
        Write-Host "Error: Not authenticated with Azure CLI. Please run 'az login' first." -ForegroundColor Red
        exit 1
    }
    Write-Host "✓ Authenticated with Azure CLI as: $($account.user.name)" -ForegroundColor Green
} catch {
    Write-Host "Error: Azure CLI not found or not working properly." -ForegroundColor Red
    Write-Host "Please install Azure CLI and run 'az login'" -ForegroundColor Yellow
    exit 1
}

# Set the subscription context
Write-Host "Setting subscription context..." -ForegroundColor Yellow
az account set --subscription $SubscriptionId
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to set subscription context" -ForegroundColor Red
    exit 1
}

# Check if resource group exists, create if it doesn't
Write-Host "Checking resource group..." -ForegroundColor Yellow
$rg = az group show --name $ResourceGroupName 2>$null | ConvertFrom-Json
if (-not $rg) {
    Write-Host "Creating resource group: $ResourceGroupName" -ForegroundColor Green
    az group create --name $ResourceGroupName --location "Central India"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to create resource group" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✓ Resource group '$ResourceGroupName' already exists" -ForegroundColor Green
}

# Deploy the ARM template
Write-Host "Deploying Azure Data Factory..." -ForegroundColor Green
$deploymentName = "adf-deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

$deployment = az deployment group create `
    --resource-group $ResourceGroupName `
    --template-file $TemplateFile `
    --parameters @$ParametersFile `
    --name $deploymentName `
    --verbose 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "Deployment completed successfully!" -ForegroundColor Green
    
    # Parse deployment outputs
    $deploymentJson = $deployment | ConvertFrom-Json
    if ($deploymentJson.outputs) {
        Write-Host "Data Factory Name: $($deploymentJson.outputs.dataFactoryName.value)" -ForegroundColor Yellow
        Write-Host "Pipeline Name: $($deploymentJson.outputs.pipelineName.value)" -ForegroundColor Yellow
        Write-Host "Resource ID: $($deploymentJson.outputs.dataFactoryResourceId.value)" -ForegroundColor Yellow
    }
} else {
    Write-Host "Deployment failed!" -ForegroundColor Red
    Write-Host $deployment
    exit 1
}