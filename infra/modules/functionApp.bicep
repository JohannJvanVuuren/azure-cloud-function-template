param location string
param functionAppName string
param functionAppKind string
param hostingServerFarmId string
param azureWebJobsStorageConnectionString string
param websiteContentAzureFileConnectionString string
param nodeVersion string
param appInsightInstrumentationKey string
param appInsightConnectionString string
param workerRuntime string
param httpsOnly bool

resource functionApp 'Microsoft.Web/sites@2025-03-01' = {
  name: functionAppName
  location: location
  kind: functionAppKind
  properties: {
    serverFarmId: hostingServerFarmId
    siteConfig: {
      nodeVersion: nodeVersion
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: azureWebJobsStorageConnectionString
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: websiteContentAzureFileConnectionString
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~20'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightInstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightConnectionString
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: workerRuntime
        }
      ]
    }
    httpsOnly: httpsOnly
  }
}

output functionAppName string = functionApp.name
output functionAppId string = functionApp.id
