Write-Output "Deleting Source Control"

$sourceControlId = $Env:SOURCE_CONTROL_ID
$Creds = $Env:CREDS | ConvertFrom-Json
$endpoint = "management.azure.com"
$subscriptionId = $Creds.subscriptionId
$tenantId = $Creds.tenantId
$resourceGroupName = $Env:RESOURCE_GROUP_NAME
$workspaceName = $Env:WORKSPACE_NAME
$envName = $Env:ENV_NAME

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
    $RawCreds = $Creds | ConvertFrom-Json

    Clear-AzContext -Scope Process;
    Clear-AzContext -Scope CurrentUser -Force -ErrorAction SilentlyContinue;
    
    Add-AzEnvironment `
        -Name $CloudEnv `
        -ActiveDirectoryEndpoint $RawCreds.activeDirectoryEndpointUrl `
        -ResourceManagerEndpoint $RawCreds.resourceManagerEndpointUrl `
        -ActiveDirectoryServiceEndpointResourceId $RawCreds.activeDirectoryServiceEndpointResourceId `
        -GraphEndpoint $RawCreds.graphEndpointUrl | out-null;

    $servicePrincipalKey = ConvertTo-SecureString $RawCreds.clientSecret.replace("'", "''") -AsPlainText -Force
    $psCredential = New-Object System.Management.Automation.PSCredential($RawCreds.clientId, $servicePrincipalKey)

    AttemptAzLogin $psCredential $RawCreds.tenantId $CloudEnv
    Set-AzContext -Tenant $RawCreds.tenantId | out-null;
}

if ($CloudEnv -ne 'AzureCloud') 
{
    Write-Output "Attempting Sign In to Azure Cloud"
    ConnectAzCloud
}
$url = "https://$endpoint/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.OperationalInsights/workspaces/$workspaceName/providers/Microsoft.SecurityInsights/sourceControls/${sourceControlId}?api-version=2021-03-01-preview"
$token = "Bearer {0}" -f (Get-AzAccessToken -Resource "https://management.azure.com").Token
$Headers = @{
    'Authorization' = $token
    'Content-Type'  = 'application/json'
##    'x-ms-repo-oauth-client-id' = 'Iv1.e1ecce06c5572019'  ## for canary
}
$response = Invoke-WebRequest -Headers $Headers -Uri $url -Method 'DELETE'
Write-Host $response 
