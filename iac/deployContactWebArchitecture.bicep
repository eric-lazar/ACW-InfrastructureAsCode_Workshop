targetScope = 'subscription'

param rgName string
param location string

@minLength(11)
@maxLength(11)
@description('YYYYMMDD with your initials to follow (i.e. 20291231acw)')
param uniqueIdentifier string

//   SQL Server Params
param sqlServerName string
param sqlDatabaseName string
param sqlServerAdminLogin string
@secure()
param sqlServerAdminPassword string
param clientIPAddress string

// Log Analytics Params
param logAnalyticsWorkspaceName string

// App Insights Params
param appInsightsName string

// web app
param webAppName string
param appServicePlanName string
param appServicePlanSku string
param identityDBConnectionStringKey string
param managerDBConnectionStringKey string
param appInsightsConnectionStringKey string


resource contactWebResourceGroup 'Microsoft.Resources/resourceGroups@2018-05-01' = {
  name: rgName
  location: location
}



module contactWebDatabase 'azureSQL.bicep' = {
  name: '${sqlServerName}-${sqlDatabaseName}-${uniqueIdentifier}'
  scope: contactWebResourceGroup
  params: {
    location: contactWebResourceGroup.location
    uniqueIdentifier: uniqueIdentifier
    sqlServerName: sqlServerName
    sqlDatabaseName: sqlDatabaseName
    sqlServerAdminLogin: sqlServerAdminLogin
    sqlServerAdminPassword: sqlServerAdminPassword
    clientIPAddress: clientIPAddress
  }
}

module contactWebAnalyticsWorkspace 'logAnalyticsWorkspace.bicep' = {
  name: '${logAnalyticsWorkspaceName}-deployment'
  scope: contactWebResourceGroup
  params: {
    location: contactWebResourceGroup.location
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
  }
}

module contactWebApplicationInsights 'applicationInsights.bicep' = {
  name: '${appInsightsName}-deployment'
  scope: contactWebResourceGroup
  params: {
    location: contactWebResourceGroup.location
    appInsightsName: appInsightsName
    logAnalyticsWorkspaceId: contactWebAnalyticsWorkspace.outputs.logAnalyticsWorkspaceId
  }
}

module contactWebApplicationPlanAndSite 'contactWebAppService.bicep' = {
  name: '${webAppName}-deployment'
  scope: contactWebResourceGroup
  params: {
    location: contactWebResourceGroup.location
    uniqueIdentifier: uniqueIdentifier
    appInsightsName: contactWebApplicationInsights.outputs.applicationInsightsName
    appServicePlanName: appServicePlanName
    appServicePlanSku: appServicePlanSku
    webAppName: webAppName
    identityDBConnectionStringKey: identityDBConnectionStringKey
    managerDBConnectionStringKey: managerDBConnectionStringKey
    appInsightsConnectionStringKey: appInsightsConnectionStringKey
  }
}
