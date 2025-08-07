# Setup Azure Key Vault secrets for secure Data Factory deployment
# This script creates the necessary secrets in Key Vault for the secure ARM template
# Updated to use Azure CLI instead of Azure PowerShell modules

param(
    [Parameter(Mandatory=$true)]
    [string]$KeyVaultName,
    
    [Parameter(Mandatory=$true)]
    [string]$StorageAccountKey,
    
    [Parameter(Mandatory=$true)]
    [string]$SqlConnectionString,
    
    [Parameter(Mandatory=$true)]
    [string]$DataFactoryPrincipalId,
    
    [Parameter(Mandatory=$false)]
    [string]$SubscriptionId
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

# Set subscription if provided
if ($SubscriptionId) {
    Write-Host "Setting subscription context..." -ForegroundColor Yellow
    az account set --subscription $SubscriptionId
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to set subscription context" -ForegroundColor Red
        exit 1
    }
}

# Check if Key Vault exists
Write-Host "Checking Key Vault..." -ForegroundColor Yellow
$keyVault = az keyvault show --name $KeyVaultName 2>$null | ConvertFrom-Json
if (-not $keyVault) {
    Write-Host "Error: Key Vault '$KeyVaultName' not found!" -ForegroundColor Red
    Write-Host "Please ensure the Key Vault exists and you have access to it." -ForegroundColor Yellow
    exit 1
}
Write-Host "✓ Key Vault '$KeyVaultName' found" -ForegroundColor Green

Write-Host "Setting up Key Vault secrets..." -ForegroundColor Green

# Set ADLS storage key secret
try {
    Write-Host "Creating storage account key secret..." -ForegroundColor Yellow
    az keyvault secret set --vault-name $KeyVaultName --name "adls-storage-key" --value $StorageAccountKey
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Storage account key secret created" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to create storage key secret" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Failed to create storage key secret: $($_.Exception.Message)" -ForegroundColor Red
}

# Set SQL connection string secret
try {
    Write-Host "Creating SQL connection string secret..." -ForegroundColor Yellow
    az keyvault secret set --vault-name $KeyVaultName --name "sql-connection-string" --value $SqlConnectionString
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ SQL connection string secret created" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to create SQL connection string secret" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Failed to create SQL connection string secret: $($_.Exception.Message)" -ForegroundColor Red
}

# Grant Data Factory access to Key Vault
try {
    Write-Host "Granting Data Factory access to Key Vault..." -ForegroundColor Yellow
    az keyvault set-policy --name $KeyVaultName --object-id $DataFactoryPrincipalId --secret-permissions get list
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Data Factory access granted to Key Vault" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to grant Data Factory access" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Failed to grant Data Factory access: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Key Vault setup complete!" -ForegroundColor Green
Write-Host "You can now deploy the secure ARM template (azuredeploy-secure.json)" -ForegroundColor Yellow

# Display next steps
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Deploy the secure ARM template: .\deploy.ps1 -ResourceGroupName 'your-rg' -SubscriptionId 'your-sub-id' -TemplateFile 'azuredeploy-secure.json'"
Write-Host "2. Update the parameters file for the secure template if needed"
Write-Host "3. Test the pipeline by uploading a CSV file and running it"