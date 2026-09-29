// =============================================================================
// main.bicep
// -----------------------------------------------------------------------------
// Orchestrator template for the Azure Cloud Function template. Composes the
// four resource modules under ./modules/ into a working Function App:
//   hostingPlan -> storageAccount -> applicationInsights -> functionApp
// The Function App module is deployed last since it consumes the outputs of
// the other three.
// =============================================================================

// -----------------------------------------------------------------------------
// Shared parameters
// -----------------------------------------------------------------------------

@description('The name of the Function App. Supporting resource names (hosting plan, storage account, Application Insights) are derived from this value. Should match the name used by the CI/CD pipeline (AZURE_FUNCTIOAPP_NAME).')
param functionAppName string

@description('The Azure region all resources are deployed to. Defaults to the resource group\'s own region.')
param location string = resourceGroup().location

// -----------------------------------------------------------------------------
// Hosting Plan (App Service Plan)
// -----------------------------------------------------------------------------

@description('The pricing SKU name for the hosting plan, e.g. "Y1" (Consumption) or "EP1" (Premium).')
param hostingPlanSKU string = 'Y1'

@description('The pricing SKU tier for the hosting plan, e.g. "Dynamic" (Consumption) or "ElasticPremium" (Premium).')
param hostingPlanSKUTier string = 'Dynamic'

@description('Derived name of the App Service Plan that hosts the Function App.')
var hostingPlanName = '${functionAppName}-plan'

module hostingPlan './modules/hostingPlan.bicep' = {
  name: 'hostingPlanDeployment'
  params: {
    hostingPlanName: hostingPlanName
    location: location
    hostingPlanSKU: hostingPlanSKU
    hostingPlanSKUTier: hostingPlanSKUTier
  }
}

// -----------------------------------------------------------------------------
// Storage Account
// -----------------------------------------------------------------------------

@description('The SKU for the storage account backing the Function App (triggers, bindings, and the content file share).')
param storageAccountSku string = 'Standard_LRS'

@description('The kind of storage account to provision.')
param storageAccountKind string = 'StorageV2'

@description('A short, deterministic, globally-unique suffix derived from the resource group ID, used to satisfy the storage account naming constraints.')
var uniqueSuffix = uniqueString(resourceGroup().id, functionAppName)

@description('Derived storage account name. Storage account names must be 3-24 characters, lowercase letters and numbers only, so the Function App name is stripped of invalid characters and a unique suffix is appended.')
var storageAccountName = take(toLower('st${replace(functionAppName, '-', '')}${uniqueSuffix}'), 24)

module storageAccount './modules/storageAccount.bicep' = {
  name: 'storageAccountDeployment'
  params: {
    storageAccountName: storageAccountName
    location: location
    storageAccountSku: storageAccountSku
    storageAccountKind: storageAccountKind
  }
}

// -----------------------------------------------------------------------------
// Application Insights
// -----------------------------------------------------------------------------

@description('The kind of Application Insights resource, e.g. "web".')
param applicationInsightsKind string = 'web'

@description('The Application Insights application type, e.g. "web".')
param applicationInsightsApplicationType string = 'web'

@description('Whether public network access for telemetry ingestion is enabled.')
param applicationInsightsPublicNetworkAccess string = 'Enabled'

@description('Whether public network access for querying telemetry is enabled.')
param applicationInsightsPublicNetworkAccessForQuery string = 'Enabled'

@description('Derived name of the Application Insights instance monitoring the Function App.')
var applicationInsightsName = '${functionAppName}-appi'

module applicationInsights './modules/applicationInsights.bicep' = {
  name: 'applicationInsightsDeployment'
  params: {
    applicationInsightsName: applicationInsightsName
    location: location
    kind: applicationInsightsKind
    applicationInsightsApplicationType: applicationInsightsApplicationType
    applicationInsightsPublicNetworkAccess: applicationInsightsPublicNetworkAccess
    applicationInsightsPublicNetworkAccessForQuery: applicationInsightsPublicNetworkAccessForQuery
  }
}

// -----------------------------------------------------------------------------
// Function App
// -----------------------------------------------------------------------------
// Deployed last: it wires together the hosting plan, storage account and
// Application Insights outputs produced above.

@description('The kind of Function App to deploy, e.g. "functionapp" (Windows) or "functionapp,linux" (Linux).')
param functionAppKind string = 'functionapp'

@description('The Node.js runtime version for the Function App, e.g. "~20". Keep this aligned with WEBSITE_NODE_DEFAULT_VERSION in functionApp.bicep and the Node.js version used by the CI/CD pipeline.')
param nodeVersion string = '~22'

@description('The Azure Functions worker runtime language.')
param workerRuntime string = 'node'

@description('Whether the Function App only accepts HTTPS traffic. Should remain true for production deployments.')
param httpsOnly bool = true

module functionApp './modules/functionApp.bicep' = {
  name: 'functionAppDeployment'
  params: {
    location: location
    functionAppName: functionAppName
    functionAppKind: functionAppKind
    hostingServerFarmId: hostingPlan.outputs.hostingPlanId
    azureWebJobsStorageConnectionString: storageAccount.outputs.azureWebJobsStorageConnectionString
    websiteContentAzureFileConnectionString: storageAccount.outputs.websiteContentAzureFileConnectionString
    nodeVersion: nodeVersion
    appInsightInstrumentationKey: applicationInsights.outputs.instrumentationKey
    appInsightConnectionString: applicationInsights.outputs.connectionString
    workerRuntime: workerRuntime
    httpsOnly: httpsOnly
  }
}

// -----------------------------------------------------------------------------
// Outputs
// -----------------------------------------------------------------------------

@description('The name of the deployed Function App.')
output functionAppName string = functionApp.outputs.functionAppName

@description('The resource ID of the deployed Function App.')
output functionAppId string = functionApp.outputs.functionAppId

@description('The name of the storage account backing the Function App.')
output storageAccountName string = storageAccount.outputs.storageAccountName

@description('The name of the Application Insights instance monitoring the Function App.')
output applicationInsightsName string = applicationInsights.outputs.applicationInsightsName
