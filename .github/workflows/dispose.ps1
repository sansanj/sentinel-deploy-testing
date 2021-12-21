Write-Output "Deleting Source Control"

$sourceControlId = $Env:SOURCE_CONTROL_ID
$Creds = $Env:CREDS | ConvertFrom-Json
$subscriptionId = $Creds.subscriptionId
$tenantId = $Creds.tenantId
$resourceGroupName = $Env:RESOURCE_GROUP_NAME
$workspaceName = $Env:WORKSPACE_NAME
$CloudEnv = $Env:CLOUD_ENV

Write-Host "cloudEnv: $CloudEnv, workspaceName: $workspaceName, resourceGroupName: $resourceGroupName, tenantId: $tenantId, subscriptionId: $subscriptionId"

function AttemptAzLogin($psCredential, $tenantId, $cloudEnv) {
    $maxLoginRetries = 3
    $delayInSeconds = 30
    $retryCount = 1
    $stopTrying = $false
    do {
        try {
            Connect-AzAccount -ServicePrincipal -Tenant $tenantId -Credential $psCredential -Environment $cloudEnv | out-null;
            Write-Host "Login Successful"
            $stopTrying = $true
        }
        catch {
            if ($retryCount -ge $maxLoginRetries) {
                Write-Host "Login failed after $maxLoginRetries attempts."
                $stopTrying = $true
            }
            else {
                Write-Host "Login attempt failed, retrying in $delayInSeconds seconds."
                Start-Sleep -Seconds $delayInSeconds
                $retryCount++
            }
        }
    }
    while (-not $stopTrying)
}

function ConnectAzCloud {
    Clear-AzContext -Scope Process;
    Clear-AzContext -Scope CurrentUser -Force -ErrorAction SilentlyContinue;
    
    Add-AzEnvironment `
        -Name $CloudEnv `
        -ActiveDirectoryEndpoint $Creds.activeDirectoryEndpointUrl `
        -ResourceManagerEndpoint $Creds.resourceManagerEndpointUrl `
        -ActiveDirectoryServiceEndpointResourceId $Creds.activeDirectoryServiceEndpointResourceId `
        -GraphEndpoint $Creds.graphEndpointUrl | out-null;

    $servicePrincipalKey = ConvertTo-SecureString $Creds.clientSecret.replace("'", "''") -AsPlainText -Force
    $psCredential = New-Object System.Management.Automation.PSCredential($Creds.clientId, $servicePrincipalKey)

    AttemptAzLogin $psCredential $Creds.tenantId $CloudEnv
    Set-AzContext -Tenant $Creds.tenantId | out-null;
}

if ($CloudEnv -ne 'AzureCloud') 
{
    Write-Output "Attempting Sign In to Azure Cloud"
    ConnectAzCloud
}

$endpoint = $Creds.resourceManagerEndpointUrl
$url = "${endpoint}subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.OperationalInsights/workspaces/$workspaceName/providers/Microsoft.SecurityInsights/sourceControls/${sourceControlId}?api-version=2021-03-01-preview"
$token = "Bearer {0}" -f (Get-AzAccessToken -Resource $endpoint).Token
$Headers = @{
    'Authorization' = $token
    'Content-Type'  = 'application/json'
##    'x-ms-repo-oauth-client-id' = 'Iv1.e1ecce06c5572019'  ## for canary
}
$response = Invoke-WebRequest -Headers $Headers -Uri $url -Method 'DELETE'
Write-Host $response 
