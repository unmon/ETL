# Azure Data Factory Deployment Script
# This script deploys the Azure Data Factory pipeline to read CSV from ADLS and load to SQL

param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory=$false)]
    [string]$ParametersFile = "azuredeploy.parameters.json",
    
    [Parameter(Mandatory=$false)]
    [string]$TemplateFile = "azuredeploy.json"
)

# Login to Azure (uncomment if needed)
# Connect-AzAccount

# Set the subscription context
Set-AzContext -SubscriptionId $SubscriptionId

# Check if resource group exists, create if it doesn't
$rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
if (-not $rg) {
    Write-Host "Creating resource group: $ResourceGroupName" -ForegroundColor Green
    New-AzResourceGroup -Name $ResourceGroupName -Location "East US"
}

# Deploy the ARM template
Write-Host "Deploying Azure Data Factory..." -ForegroundColor Green
$deployment = New-AzResourceGroupDeployment `
    -ResourceGroupName $ResourceGroupName `
    -TemplateFile $TemplateFile `
    -TemplateParameterFile $ParametersFile `
    -Verbose

if ($deployment.ProvisioningState -eq "Succeeded") {
    Write-Host "Deployment completed successfully!" -ForegroundColor Green
    Write-Host "Data Factory Name: $($deployment.Outputs.dataFactoryName.Value)" -ForegroundColor Yellow
    Write-Host "Pipeline Name: $($deployment.Outputs.pipelineName.Value)" -ForegroundColor Yellow
    Write-Host "Resource ID: $($deployment.Outputs.dataFactoryResourceId.Value)" -ForegroundColor Yellow
} else {
    Write-Host "Deployment failed!" -ForegroundColor Red
    Write-Host $deployment
}