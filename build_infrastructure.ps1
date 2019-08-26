$resourceGroup = "DevOpsResourceGroup"
$storageAccount = "hwdevopsfuncstorage"
$functionApp = "HwDevOpsFunctionApp"
$keyVaultName = "HwDevOpsKeyVault"
$servicePrincipalName = "9d25a2db-56c8-48f9-bdad-3f773fa22478"

az group create --name $resourceGroup --location westus
az storage account create --resource-group $resourceGroup --name $storageAccount --assign-identity --location westus --sku Standard_LRS
az functionapp create --consumption-plan-location westus --resource-group $resourceGroup --name $functionApp  --runtime node --storage-account $storageAccount
az functionapp config appsettings set --resource-group $resourceGroup --name $functionApp --slot-settings "WEBSITE_RUN_FROM_PACKAGE=1"
az functionapp deployment slot create --resource-group $resourceGroup --name $functionApp --slot staging
az keyvault create --resource-group $resourceGroup --name $keyVaultName --location westus --sku standard

az keyvault secret set --vault-name $keyVaultName --name "Secret1" --value "SuperSecret1"
az keyvault secret set --vault-name $keyVaultName --name "Secret2" --value "SuperSecret2"
az keyvault secret set --vault-name $keyVaultName --name "Secret3" --value "SuperSecret3"
az keyvault secret set --vault-name $keyVaultName --name "Secret4" --value "SuperSecret4"
az keyvault secret set --vault-name $keyVaultName --name "Secret5" --value "SuperSecret5"

#$servicePrincipalObjectId = az ad sp show --id $servicePrincipalName --query "objectId"
az keyvault set-policy --resource-group $resourceGroup --name $keyVaultName --spn $servicePrincipalName --secret-permissions get list