Write-Output "Deleting Source Control"

$sourceControlId = $Env:SOURCE_CONTROL_ID
$Creds = $Env:CREDS | ConvertFrom-Json
$endpoint = "management.azure.com"
$subscriptionId = $Creds.subscriptionId
$tenantId = $Creds.tenantId
$resourceGroupName = $Env:RESOURCE_GROUP_NAME
$workspaceName = $Env:WORKSPACE_NAME
Write-Host $subscriptionId
Write-Host $tenantId

$url = "https://$endpoint/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.OperationalInsights/workspaces/$workspaceName/providers/Microsoft.SecurityInsights/sourceControls/${sourceControlId}?api-version=2021-03-01-preview"
$tokenResult = Get-AzAccessToken
Write-Host $tokenResult.UserId
$response = Invoke-WebRequest $url -Authentication Bearer -Token $tokenResult.Token -Method 'DELETE'
Write-Host $ProfileResponse
