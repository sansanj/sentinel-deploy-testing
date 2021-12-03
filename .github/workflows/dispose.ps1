Write-Output "Deleting Source Control"

$sourceControlId = $Env:SOURCE_CONTROL_ID
$Creds = $Env:CREDS | ConvertFrom-Json
$endpoint = "management.azure.com"
$subscriptionId = ConvertFrom-SecureString -SecureString $Creds.subscriptionId -AsPlainText
$tenantId = ConvertFrom-SecureString -SecureString $Creds.tenantId -AsPlainText
$resourceGroupName = "test-rg" # $Env:RESOURCE_GROUP_NAME
$workspaceName = "test-rws" # $Env:WORKSPACE_NAME
Write-Host $subscriptionId
Write-Host $tenantId

$url = "https://$endpoint/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.OperationalInsights/workspaces/$workspaceName/providers/Microsoft.SecurityInsights/sourceControls/$sourceControlId?api-version=2021-03-01-preview"
Write-Host $url
