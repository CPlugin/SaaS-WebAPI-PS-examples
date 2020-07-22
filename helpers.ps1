#clear
#using namespace IdentityModel.Client;
#using namespace System.Net.Http;
$VerbosePreference = [System.Management.Automation.ActionPreference]::Continue
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

if($null -eq $PSScriptRoot){
    $PSScriptRoot = [System.IO.Directory]::GetCurrentDirectory()
    #$PSScriptRoot
}
[Reflection.Assembly]::LoadWithPartialName("System.Net.Http")
[Reflection.Assembly]::LoadFile($PSScriptRoot + "/Newtonsoft.Json.dll")
[Reflection.Assembly]::LoadFile($PSScriptRoot + "/IdentityModel.dll")

########################### helper functions ##########################
function authAsClient($clientId, $clientSecret) {
    # ==============
    # auth as a client
    # ==============
    if ($null -eq $env:SaaSIdSrv) {
        #'==> using production idsrv' | Write-Host -BackgroundColor DarkYellow
        $env:SaaSIdSrv = "https://auth.cplugin.net"
    }

    [System.Net.Http.HttpClientHandler]$handler = New-Object 'System.Net.Http.HttpClientHandler'

    "==> authenticating against $($env:SaaSIdSrv)..." | Write-Host -BackgroundColor Green
    $client = [IdentityModel.Client.TokenClient]::new("$($env:SaaSIdSrv)/connect/token", $clientId, $clientSecret, $handler, [IdentityModel.Client.AuthenticationStyle]::BasicAuthentication)
    #"client.Address: $($client.Address)" | Write-Host
    # | Write-Host -BackgroundColor Green

    [IdentityModel.Client.TokenResponse]$authResult = [IdentityModel.Client.TokenClientExtensions]::RequestClientCredentialsAsync($client, "webapi").GetAwaiter().GetResult()
    #.Result
    #.GetAwaiter().GetResult()

    if($authResult.IsError) {
        "auth has error" | Write-Error
        $authResult.Exception.ToString() | Write-Error
        if($null -ne $authResult.InnerException) {
            $authResult.InnerException.ToString() | Write-Error
        }
    }

    #$authResult | Format-List | Write-Host -BackgroundColor Green

    #"==> authResult: '$($authResult.Raw)'" | Write-Host #-BackgroundColor Green
    #$authResult.Raw | Write-Host

    if ($authResult -ne $null -and $authResult.AccessToken -ne $null) {
        '==> done!' | Write-Host -BackgroundColor Green
    }
    else {
        '==> failed!' | Write-Host -BackgroundColor Red
        $authResult | Write-Host -BackgroundColor Red
        throw "Authorization failed"
    }

    #"authResult:" | Write-Host -BackgroundColor Black
    #$authResult | Format-List

    $auth_headers = @{
        "Authorization" = "Bearer " + $authResult.AccessToken
    }

    return $auth_headers
}

Function rest_get {
    [CmdletBinding(
        SupportsShouldProcess = $True,
        ConfirmImpact = "Low"
    )]
    Param(
        [parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromPipeline = $true)]
        [string]$Url = ""
    )

    if ($env:SaaSWebAPI -eq $null) {
        $env:SaaSWebAPI = "https://MyWebAPI.com"
    }

    try {
        #$url | Write-Host -BackgroundColor Black
        Invoke-RestMethod -Uri ($env:SaaSWebAPI + $url)  -ContentType "application/json" -Headers $auth_headers -Verbose -MaximumRedirection 0
        ($url + " done") | Write-Verbose
    }
    catch {
        # Dig into the exception to get the Response details.
        # Note that value__ is not a typo.

        Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ -ForegroundColor Red
        Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription -ForegroundColor Red

        $streamReader = New-Object System.IO.StreamReader $_.Exception.Response.GetResponseStream()
        try {
            $data = $streamReader.ReadToEnd()
            $results = $data #| ConvertFrom-Json
            $results | Write-Host  -ForegroundColor Red
        }
        finally {
            $streamReader.Dispose()
        }

        #$_.Exception.Response.GetResponseStream(). | Write-Host  -ForegroundColor Red

        # ErrorType ErrorCode ErrorDescription RequestId
    }
}

function rest_get_single($url) {
    "Result: " + (rest_get $url)
}

function rest_get_list($url) {
    (rest_get $url) | Format-List
}

function rest_get_table($url) {
    (rest_get $url) | Format-Table
}

function rest_put($url, $data = $null) {
    if ($env:SaaSWebAPI -eq $null) {
        $env:SaaSWebAPI = "https://MyWebAPI.com"
    }

    try {
        #$url | Write-Host -BackgroundColor Black
        Invoke-RestMethod -Method Put -Uri ($env:SaaSWebAPI + $url)  -ContentType "application/json" -Headers $auth_headers -Verbose -MaximumRedirection 0 | Format-List
        ($url + " done") | Write-Verbose
    }
    catch {
        # Dig into the exception to get the Response details.
        # Note that value__ is not a typo.

        Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ -ForegroundColor Red
        Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription -ForegroundColor Red

        $streamReader = New-Object System.IO.StreamReader $_.Exception.Response.GetResponseStream()
        try {
            $data = $streamReader.ReadToEnd()
            $results = $data #| ConvertFrom-Json
            $results | Write-Host  -ForegroundColor Red
        }
        finally {
            $streamReader.Dispose()
        }

        #$_.Exception.Response.GetResponseStream(). | Write-Host  -ForegroundColor Red

        # ErrorType ErrorCode ErrorDescription RequestId
    }
}

function rest_post($url, $data = $null) {
    if ($env:SaaSWebAPI -eq $null) {
        $env:SaaSWebAPI = "https://MyWebAPI.com"
    }
    "posting : " + $data
    try {
        #$url | Write-Host -BackgroundColor Black
        Invoke-RestMethod -Method Post -Uri ($env:SaaSWebAPI + $url)  -ContentType "application/json" -Headers $auth_headers -Verbose -MaximumRedirection 0 -Body $data | Format-List
        ($url + " done") | Write-Verbose
    }
    catch {
        # Dig into the exception to get the Response details.
        # Note that value__ is not a typo.

        Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ -ForegroundColor Red
        Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription -ForegroundColor Red

        $streamReader = New-Object System.IO.StreamReader $_.Exception.Response.GetResponseStream()
        try {
            $data = $streamReader.ReadToEnd()
            $results = $data # | ConvertFrom-Json
            $results | Write-Host  -ForegroundColor Red
        }
        finally {
            $streamReader.Dispose()
        }

        #$_.Exception.Response.GetResponseStream(). | Write-Host  -ForegroundColor Red

        # ErrorType ErrorCode ErrorDescription RequestId
    }
}
