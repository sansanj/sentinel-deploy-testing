Write-Output "Deleting Source Control"

$sourceControlId = $Env:SOURCE_CONTROL_ID
$Creds = $Env:CREDS | ConvertFrom-Json
$endpoint = "management.azure.com"
$subscriptionId = $Creds.subscriptionId
$tenantId = $Creds.tenantId
$resourceGroupName = $Env:RESOURCE_GROUP_NAME
$workspaceName = $Env:WORKSPACE_NAME

$url = "https://$endpoint/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.OperationalInsights/workspaces/$workspaceName/providers/Microsoft.SecurityInsights/sourceControls/${sourceControlId}?api-version=2021-03-01-preview"
$token = "Bearer {0}" -f (Get-AzAccessToken -Resource "https://management.azure.com").Token
$Headers = @{
    'Authorization' = $token
    "Content-Type"  = 'application/json'
}
$response = Invoke-WebRequest -Headers $Headers -Uri $url -Method 'DELETE'
Write-Host $ProfileResponse
