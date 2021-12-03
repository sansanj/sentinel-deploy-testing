Write-Output "Deleting Source Control"

$sourceControlId = $Env:SOURCE_CONTROL_ID
$Creds = $env.CREDS | ConvertFrom-Json
Write-Host $Creds.tenantId
Write-Host $Creds.subscriptionId
