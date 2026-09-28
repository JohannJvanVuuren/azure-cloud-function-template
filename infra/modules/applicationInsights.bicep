param applicationInsightsName string
param location string
param kind string
param applicationInsightsApplicationType string
param applicationInsightsPublicNetworkAccess string
param applicationInsightsPublicNetworkAccessForQuery string

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: kind
  properties: {
    Application_Type: applicationInsightsApplicationType
    publicNetworkAccessForIngestion: applicationInsightsPublicNetworkAccess
    publicNetworkAccessForQuery: applicationInsightsPublicNetworkAccessForQuery
  }
}

output applicationInsightsName string = applicationInsights.name
output instrumentationKey string = applicationInsights.properties.InstrumentationKey
output connectionString string = applicationInsights.properties.ConnectionString
