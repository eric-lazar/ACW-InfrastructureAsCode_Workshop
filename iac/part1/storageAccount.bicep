
//az deployment group create --resource-group $rg --template-file storageAccount.bicep --parameters storageAccount.parameters.json

param storageAccountName string
param location string = resourceGroup().location
param uniqueIdentifier string
//param deploymentEnvironment string

//var storageAccountNameFull = '${storageAccountName}${uniqueIdentifier}${uniqueString(resourceGroup().id)}'
var storageAccountNameFull = '${storageAccountName}${uniqueIdentifier}'

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountNameFull
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}


output storageAccountName string = storageaccount.name
output storageAccountId string = storageaccount.id
output storageAccountLocation string = storageaccount.location

