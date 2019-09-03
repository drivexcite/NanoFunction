# az ad sp create-for-rbac -n "AzureDevOps.EvilHealthwise.Platform2" --role owner
# {
#   "appId": "clientId",
#   "displayName": "AzureDevOps.EvilHealthwise.Platform2",
#   "name": "http://AzureDevOps.EvilHealthwise.Platform2",
#   "password": "secret",
#   "tenant": "tenant"
# }

# To prevent interactive mode from interrupting the scripts, set these environment variables.
$tenant = "tenant"
$servicePrincipalName = "clientId"
$azureSubscription = "subscriptionId"
$subscriptionName = "Visual Studio Enterprise"

$env:AZURE_DEVOPS_EXT_GITHUB_PAT="github pat"
$env:AZURE_DEVOPS_EXT_AZURE_RM_SERVICE_PRINCIPAL_KEY="secret"
$env:AZURE_DEVOPS_EXT_PAT = 'azure devops pat'
$env:AZURE_DEVOPS_EXT_BITBUCKET_USERNAME="bitBucketUser"
$env:AZURE_DEVOPS_EXT_BITBUCKET_PAT="bitBucketPAT"

# Variables for pipeline and repository related artifacts
$Organization = 'https://dev.azure.com/EvilHealthwise'
$Project = 'Nanofunction'

$AzureRmServiceConnectionName = "AzureVsEnterprise"
$GitHubServiceConnectionName = "GitHubTona"
$PipelineName = "NanoFunction"
$PipelineDescription = "NanoFunction App Deploy"
$GitHubRepoUrl = "https://github.com/drivexcite/nanofunction"

# Variables for Azure Related Artifacts
$resourceGroup = 'DevOpsResourceGroup'
$functionApp = 'HwDevOpsFunctionApp'
$slotName = 'staging'
$keyVaultName = "HwDevOpsKeyVault"


# Login to Azure DevOps
$env:AZURE_DEVOPS_EXT_PAT |  az devops login --organization $Organization

# Create the Project
az devops project create --name $project --organization $organization --visibility private
az devops configure --defaults organization=$Organization project=$Project

# 'Create' users
az devops user add --email-id ajackson@healthwise.org --license-type stakeholder --send-email-invite false
az devops user add --email-id acarr@healthwise.org --license-type stakeholder --send-email-invite false
az devops user add --email-id dray@healthwise.org --license-type stakeholder --send-email-invite false
az devops user add --email-id emassaquoi@healthwise.org --license-type stakeholder --send-email-invite false
az devops user add --email-id mlyons@healthwise.org --license-type stakeholder --send-email-invite false
az devops user add --email-id gcolby@healthwise.org --license-type stakeholder --send-email-invite false
az devops user add --email-id medvalson@healthwise.org --license-type stakeholder --send-email-invite false
az devops user add --email-id tstclair@healthwise.org --license-type stakeholder --send-email-invite false

# Service connections
$azureServiceConnectionId = az devops service-endpoint azurerm create --name $AzureRmServiceConnectionName --azure-rm-service-principal-id $servicePrincipalName --azure-rm-subscription-id $azureSubscription --azure-rm-subscription-name $subscriptionName --azure-rm-tenant-id $tenant --query "id"
$githubServiceConnectionId = az devops service-endpoint github create --github-url $GitHubRepoUrl --name $GitHubServiceConnectionName --query "id"

$bitBucketServiceDefinition = Get-Content -Path .\BitBucketServiceConnectionTemplate.json
$bitBucketServiceConnection =  $bitBucketServiceDefinition.Replace("BitBucketUserName", $env:AZURE_DEVOPS_EXT_BITBUCKET_USERNAME).Replace("BitBucketPAT", $env:AZURE_DEVOPS_EXT_BITBUCKET_PAT)
$bitBucketServiceConnection | Out-File -FilePath .\BitBucketServiceConnectionDefinition.json

# https://docs.microsoft.com/en-us/azure/devops/cli/service_endpoint?view=azure-devops
$bitBucketServiceConnectionId = az devops service-endpoint create --service-endpoint-configuration BitBucketServiceConnectionDefinition.json --query "id"

# Create the pipeline
az pipelines create --name $PipelineName --description $PipelineDescription --repository $GitHubRepoUrl --branch master --repository-type github --service-connection $azureServiceConnectionId --service-connection $githubServiceConnectionId --service-connection $bitBucketServiceConnectionId --yml-path azure-pipelines.yml

# Create a variable group
$variableGroupName = "nanofunction-pipeline-variables"
az pipelines variable-group create --name $variableGroupName --authorize true --variables azureServiceConnection=$AzureRmServiceConnectionName startingVersion=1.0 functionAppName=$functionApp slotName=$slotName resourceGroupName=$resourceGroup keyVaultName=$keyVaultName

# Trigger the build
# az pipelines build queue --definition-name $PipelineName --branch master --open

#Swap slots
# az functionapp deployment slot swap  -g $resourceGroup -n $functionApp --slot $slotName --target-slot production