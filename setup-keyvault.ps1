# Setup Azure Key Vault secrets for secure Data Factory deployment
# This script creates the necessary secrets in Key Vault for the secure ARM template

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

# Set subscription if provided
if ($SubscriptionId) {
    Set-AzContext -SubscriptionId $SubscriptionId
}

# Check if Key Vault exists
$keyVault = Get-AzKeyVault -VaultName $KeyVaultName -ErrorAction SilentlyContinue
if (-not $keyVault) {
    Write-Host "Error: Key Vault '$KeyVaultName' not found!" -ForegroundColor Red
    exit 1
}

Write-Host "Setting up Key Vault secrets..." -ForegroundColor Green

# Set ADLS storage key secret
try {
    $storageKeySecure = ConvertTo-SecureString -String $StorageAccountKey -AsPlainText -Force
    Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name "adls-storage-key" -SecretValue $storageKeySecure
    Write-Host "✓ Storage account key secret created" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to create storage key secret: $($_.Exception.Message)" -ForegroundColor Red
}

# Set SQL connection string secret
try {
    $sqlConnectionSecure = ConvertTo-SecureString -String $SqlConnectionString -AsPlainText -Force
    Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name "sql-connection-string" -SecretValue $sqlConnectionSecure
    Write-Host "✓ SQL connection string secret created" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to create SQL connection string secret: $($_.Exception.Message)" -ForegroundColor Red
}

# Grant Data Factory access to Key Vault
try {
    Set-AzKeyVaultAccessPolicy -VaultName $KeyVaultName -ObjectId $DataFactoryPrincipalId -PermissionsToSecrets Get,List
    Write-Host "✓ Data Factory access granted to Key Vault" -ForegroundColor Green
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