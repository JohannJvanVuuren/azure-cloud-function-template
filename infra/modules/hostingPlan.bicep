param hostingPlanName string
param location string
param hostingPlanSKU string
param hostingPlanSKUTier string

resource hostingPlan 'Microsoft.Web/serverfarms@2025-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: hostingPlanSKU
    tier: hostingPlanSKUTier
  }
  properties: {}
}

output hostingPlanId string = hostingPlan.id
