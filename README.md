# Azure Data Factory: CSV to SQL Pipeline

This repository contains an Azure Data Factory (ADF) pipeline that reads data from a CSV file stored in Azure Data Lake Storage (ADLS) and loads it into an Azure SQL Database table.

## Architecture Overview

The solution consists of the following components:

1. **Azure Data Factory** - Orchestrates the data movement
2. **Azure Data Lake Storage (ADLS)** - Source storage for CSV files
3. **Azure SQL Database** - Destination for the processed data
4. **Linked Services** - Connections to ADLS and SQL Database
5. **Datasets** - Define the structure of source CSV and destination SQL table
6. **Pipeline** - Contains the copy activity to move data

## Prerequisites

- Azure subscription
- Azure CLI or PowerShell with Azure modules
- Azure Data Lake Storage account (Gen2)
- Azure SQL Database (or SQL Server)
- Appropriate permissions to create resources

## File Structure

```
├── azuredeploy.json                 # Main ARM template
├── azuredeploy.parameters.json      # Parameters template
├── deploy.ps1                       # PowerShell deployment script
├── deploy.sh                        # Bash deployment script
├── sql-scripts/
│   └── create-table.sql            # SQL script to create destination table
├── sample-data/
│   └── sample.csv                  # Sample CSV file for testing
└── README.md                       # This documentation
```

## Quick Start

### 1. Clone and Configure

```bash
# Clone or download this repository
git clone <repository-url>
cd azure-data-factory-csv-to-sql
```

### 2. Update Parameters

Edit `azuredeploy.parameters.json` with your actual values:

```json
{
  "dataFactoryName": { "value": "your-unique-adf-name" },
  "storageAccountName": { "value": "youradlsaccount" },
  "storageAccountKey": { "value": "your-storage-key" },
  "sqlServerName": { "value": "your-sql-server" },
  "sqlDatabaseName": { "value": "your-database" },
  "sqlUsername": { "value": "your-username" },
  "sqlPassword": { "value": "your-password" },
  "csvFilePath": { "value": "your-csv-path" },
  "sqlTableName": { "value": "dbo.YourTableName" }
}
```

### 3. Prepare Your Environment

#### Create SQL Table
Run the SQL script to create your destination table:

```sql
-- Modify sql-scripts/create-table.sql based on your CSV structure
-- Then execute it in your Azure SQL Database
```

#### Upload CSV File
Upload your CSV file to ADLS:

```bash
# Using Azure CLI
az storage fs file upload \
    --account-name youradlsaccount \
    --file-system data \
    --source ./sample-data/sample.csv \
    --path input/sample.csv
```

### 4. Deploy

#### Using PowerShell:
```powershell
.\deploy.ps1 -ResourceGroupName "your-rg" -SubscriptionId "your-subscription-id"
```

#### Using Bash:
```bash
chmod +x deploy.sh
./deploy.sh -g "your-rg" -s "your-subscription-id"
```

#### Using Azure CLI directly:
```bash
az deployment group create \
    --resource-group "your-rg" \
    --template-file azuredeploy.json \
    --parameters @azuredeploy.parameters.json
```

## Configuration Details

### Linked Services

1. **ADLS Linked Service**
   - Type: AzureBlobFS
   - Authentication: Account Key
   - URL: `https://{storage-account}.dfs.core.windows.net`

2. **SQL Linked Service**
   - Type: AzureSqlDatabase
   - Authentication: SQL Authentication
   - Connection String: Auto-generated from parameters

### Datasets

1. **CSV Dataset**
   - Type: DelimitedText
   - Location: AzureBlobFSLocation
   - Settings: Comma-delimited, first row as header

2. **SQL Dataset**
   - Type: AzureSqlTable
   - Table: Configurable via parameters

### Pipeline Activities

1. **Copy Activity**
   - Source: DelimitedTextSource (CSV from ADLS)
   - Sink: AzureSqlSink (SQL Database table)
   - Features: Pre-copy script (TRUNCATE), automatic type conversion

## Customization Options

### Modify CSV Format
Update the CSV dataset properties in the ARM template:

```json
"typeProperties": {
  "columnDelimiter": ";",      // Change delimiter
  "firstRowAsHeader": false,   // No header row
  "quoteChar": "'"            // Different quote character
}
```

### Add Data Transformations
To add data transformations, consider using:
- Data Flow activities
- Mapping transformations
- Expression builder for column mappings

### Error Handling
Add error handling by:
- Configuring retry policies
- Adding failure activities
- Setting up monitoring and alerts

## Monitoring and Troubleshooting

### Monitor Pipeline Runs
1. Go to Azure Data Factory Studio
2. Navigate to Monitor > Pipeline runs
3. View execution details and logs

### Common Issues

1. **Connection Failures**
   - Verify firewall settings on SQL Database
   - Check ADLS access permissions
   - Validate connection strings

2. **Schema Mismatches**
   - Ensure CSV columns match SQL table structure
   - Check data type compatibility
   - Review column mappings

3. **Performance Issues**
   - Increase Data Integration Units (DIUs)
   - Enable staging for large datasets
   - Optimize SQL table indexes

## Security Best Practices

1. **Use Managed Identity**
   - Replace account keys with managed identity authentication
   - Grant appropriate RBAC roles

2. **Azure Key Vault Integration**
   - Store sensitive connection strings in Key Vault
   - Reference secrets in linked services

3. **Network Security**
   - Use private endpoints for ADLS and SQL Database
   - Configure virtual network integration

## Cost Optimization

1. **Schedule Optimization**
   - Run pipelines during off-peak hours
   - Use triggers instead of continuous monitoring

2. **Resource Sizing**
   - Right-size Data Integration Units
   - Use auto-pause for SQL Database when possible

## Advanced Features

### Parameterization
The pipeline supports dynamic file paths and table names:

```json
{
  "csvFilePath": "data/@{formatDateTime(utcnow(), 'yyyy/MM/dd')}/file.csv",
  "sqlTableName": "dbo.Data_@{formatDateTime(utcnow(), 'yyyyMMdd')}"
}
```

### Scheduling
Add triggers to the ARM template:

```json
{
  "type": "Microsoft.DataFactory/factories/triggers",
  "apiVersion": "2018-06-01",
  "name": "DailyTrigger",
  "properties": {
    "type": "ScheduleTrigger",
    "typeProperties": {
      "recurrence": {
        "frequency": "Day",
        "interval": 1,
        "startTime": "2024-01-01T02:00:00Z"
      }
    }
  }
}
```

## Support and Contributing

For issues and questions:
1. Check the troubleshooting section
2. Review Azure Data Factory documentation
3. Open an issue in this repository

## License

This project is licensed under the MIT License - see the LICENSE file for details.