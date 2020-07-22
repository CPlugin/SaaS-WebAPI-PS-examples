. "$PSScriptRoot/helpers.ps1"

#webapi
$clientId = "***"
$clientSecret = "***"

#MT4 id
$tradePlatformId="***"

# if settings file exist, override above settings
if([System.IO.File]::Exists("$PSScriptRoot/settings.ps1")) {
    . "$PSScriptRoot/settings.ps1"
}

########################### main code ##########################

$auth_headers = authAsClient -clientId $clientId -clientSecret $clientSecret

'==> calling webapi...'

# simple ping of MT4 server
rest_get "/api/TradePlatforms/$tradePlatformId/Ping"



'==> done!'

