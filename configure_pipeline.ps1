 # Azure DevOps PAT = foo
 # GitHub PAT = bar

# az ad sp create-for-rbac -n "AzureDevOps.EvilHealthwise.Platform2" --role owner
# {
#   "appId": "9d25a2db-56c8-48f9-bdad-3f773fa22478",
#   "displayName": "AzureDevOps.EvilHealthwise.Platform2",
#   "name": "http://AzureDevOps.EvilHealthwise.Platform2",
#   "password": "baz",
#   "tenant": "cee5d4e9-42e5-48c2-8a03-3406fd5b9242"
# }

# To prevent interactive mode from interrupting the scripts, set these environment variables.
$env:AZURE_DEVOPS_EXT_GITHUB_PAT="bar"
$env:AZURE_DEVOPS_EXT_AZURE_RM_SERVICE_PRINCIPAL_KEY="baz"

# Variables for pipeline and repository related artifacts
$AzureRmServiceConnectionName = "AzureVsEnterprise"
$GitHubServiceConnectionName = "GitHubTona"
$PipelineName = "NanoFunction App Deploy"
$PipelineDescription = "NanoFunction App Deploy"
$GitHubRepoUrl = "https://github.com/drivexcite/nanofunction"

# Variables for Azure Related Artifacts
$resourceGroup = 'DevOpsResourceGroup'
$functionApp = 'HwDevOpsFunctionApp'

az devops configure --defaults organization=https://dev.azure.com/EvilHealthwise project=Platform

# Service connections
$azureServiceConnectionId = az devops service-endpoint azurerm create --name $AzureRmServiceConnectionName --azure-rm-service-principal-id "9d25a2db-56c8-48f9-bdad-3f773fa22478" --azure-rm-subscription-id "45d3970c-1cf3-47f8-86fa-ae717be4baa9" --azure-rm-subscription-name "Visual Studio Enterprise" --azure-rm-tenant-id "cee5d4e9-42e5-48c2-8a03-3406fd5b9242" --query "id"
$githubServiceConnectionId = az devops service-endpoint github create --github-url $GitHubRepoUrl --name $GitHubServiceConnectionName --query "id"

# Create the pipeline (must be run interactively)
az pipelines create --name $PipelineName --description $PipelineDescription --repository $GitHubRepoUrl --branch master --repository-type github --service-connection $azureServiceConnectionId --service-connection $githubServiceConnectionId

# Create a variable group
$variableGroupName = "nanofunction-pipeline-variables"
az pipelines variable-group create --name $variableGroupName --authorize true --variables azureServiceConnection=$AzureRmServiceConnectionName startingVersion=1.0 targetFunctionAppName=$functionApp resourceGroupName=$resourceGroup