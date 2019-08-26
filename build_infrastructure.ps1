$resourceGroup = 'DevOpsResourceGroup'
$storageAccount = 'hwdevopsfuncstorage'
$webAppPlan = 'DevOpsWebAppPlan'
$functionApp = 'HwDevOpsFunctionApp'

az group create --name $resourceGroup --location westus
az storage account create --resource-group $resourceGroup --name $storageAccount --assign-identity --location westus --sku Standard_LRS
az appservice plan create --resource-group $resourceGroup --name $webAppPlan --is-linux --location westus --sku B1
az functionapp create --resource-group $resourceGroup --name $functionApp --plan $webAppPlan --os-type Linux  --runtime node --storage-account $storageAccount