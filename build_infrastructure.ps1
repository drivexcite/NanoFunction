$resourceGroup = 'DevOpsResourceGroup'
$storageAccount = 'hwdevopsfuncstorage'
$functionApp = 'HwDevOpsFunctionApp'

az group create --name $resourceGroup --location westus
az storage account create --resource-group $resourceGroup --name $storageAccount --assign-identity --location westus --sku Standard_LRS
az functionapp create --consumption-plan-location westus --resource-group $resourceGroup --name $functionApp  --runtime node --storage-account $storageAccount
az functionapp config appsettings set --resource-group $resourceGroup --name $functionApp --slot-settings "WEBSITE_RUN_FROM_PACKAGE=1"
az functionapp deployment slot create --resource-group $resourceGroup --name $functionApp --slot staging