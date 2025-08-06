#!/bin/bash

# Azure Data Factory Deployment Script
# This script deploys the Azure Data Factory pipeline to read CSV from ADLS and load to SQL

# Set variables
RESOURCE_GROUP_NAME=""
SUBSCRIPTION_ID=""
PARAMETERS_FILE="azuredeploy.parameters.json"
TEMPLATE_FILE="azuredeploy.json"
LOCATION="East US"

# Function to display usage
usage() {
    echo "Usage: $0 -g <resource-group> -s <subscription-id> [-p <parameters-file>] [-t <template-file>] [-l <location>]"
    echo "  -g: Resource group name (required)"
    echo "  -s: Subscription ID (required)"
    echo "  -p: Parameters file (default: azuredeploy.parameters.json)"
    echo "  -t: Template file (default: azuredeploy.json)"
    echo "  -l: Location (default: East US)"
    exit 1
}

# Parse command line arguments
while getopts "g:s:p:t:l:h" opt; do
    case $opt in
        g) RESOURCE_GROUP_NAME="$OPTARG" ;;
        s) SUBSCRIPTION_ID="$OPTARG" ;;
        p) PARAMETERS_FILE="$OPTARG" ;;
        t) TEMPLATE_FILE="$OPTARG" ;;
        l) LOCATION="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Check required parameters
if [ -z "$RESOURCE_GROUP_NAME" ] || [ -z "$SUBSCRIPTION_ID" ]; then
    echo "Error: Resource group name and subscription ID are required"
    usage
fi

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "Error: Azure CLI is not installed or not in PATH"
    exit 1
fi

# Login to Azure (uncomment if needed)
# az login

# Set the subscription
echo "Setting subscription to: $SUBSCRIPTION_ID"
az account set --subscription "$SUBSCRIPTION_ID"

# Check if resource group exists, create if it doesn't
echo "Checking if resource group exists: $RESOURCE_GROUP_NAME"
if ! az group show --name "$RESOURCE_GROUP_NAME" &> /dev/null; then
    echo "Creating resource group: $RESOURCE_GROUP_NAME in $LOCATION"
    az group create --name "$RESOURCE_GROUP_NAME" --location "$LOCATION"
fi

# Deploy the ARM template
echo "Deploying Azure Data Factory..."
DEPLOYMENT_OUTPUT=$(az deployment group create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --template-file "$TEMPLATE_FILE" \
    --parameters "@$PARAMETERS_FILE" \
    --query '{provisioningState:properties.provisioningState, dataFactoryName:properties.outputs.dataFactoryName.value, pipelineName:properties.outputs.pipelineName.value, resourceId:properties.outputs.dataFactoryResourceId.value}' \
    --output json)

if [ $? -eq 0 ]; then
    echo "Deployment completed successfully!"
    echo "Deployment details:"
    echo "$DEPLOYMENT_OUTPUT" | jq .
else
    echo "Deployment failed!"
    exit 1
fi

echo ""
echo "Next steps:"
echo "1. Update the parameters file with your actual values"
echo "2. Ensure your SQL table exists with the correct schema"
echo "3. Upload your CSV file to the specified ADLS path"
echo "4. Trigger the pipeline manually or set up a schedule"