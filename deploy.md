# Create a resource group
az group create --name rg-ts-functions --location eastus

# Deploy the Bicep template
az deployment group create \
--resource-group rg-ts-functions \
--template-file infrastructure/main.bicep

# Deploy Function Code
func azure functionapp publish <YOUR_FUNCTION_APP_NAME>