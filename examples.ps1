. "$PSScriptRoot/helpers.ps1"

#webapi
$clientId = "***"
$clientSecret = "***"

#MT4 id
$tradePlatformId="***"
#  to get it, navigate to https://admin.cplugin.net/TradePlatforms, when click on rename, and get ID from URL end in naviagtion bar

# if settings file exist, override above settings
if([System.IO.File]::Exists("$PSScriptRoot/settings.ps1")) {
    . "$PSScriptRoot/settings.ps1"
}

########################### main code ##########################
$auth_headers = authAsClient -clientId $clientId -clientSecret $clientSecret

# for more information about WebAPI methods and parameters please have a look at https://mywebapi.com/swagger/index.html


############ uncomment needed part of code #######


### simple ping of MT4 server
rest_get "/api/TradePlatforms/$tradePlatformId/Ping"


### create balance operation (deposit $100 to acount `1000`)
# rest_post -url "/api/MT4/$tradePlatformId/TradeTransaction" -data "{'tradeTransactionType':'BrBalance', 'tradeCommand':'Balance', 'orderBy':1000, 'price':100}"


### get all users
# rest_get_list "/API/MT4/$tradePlatformId/UsersGet"


### get all open orders
# rest_get_list "/API/MT4/$tradePlatformId/TradesGet"


### close all open orders on account `1000`
#<#
$login = 1000
# 1. get user records details
$userRecord = rest_get "/API/MT4/$tradePlatformId/UserRecordGet/$login"
$userRecord

# get all open orders for user's group
$tradeRecords = (rest_get "/API/MT4/$tradePlatformId/AdmTradesRequest/$($userRecord.group)/true").Where({$_.login -eq $login})
$tradeRecords | Format-Table

foreach ($tr in $tradeRecords) {

    $tradeTransactionType = 'BrClose'

    # pending orders to be deleted, instead of closing
    if($tr.tradeCommand -in @('BuyLimit', 'SellLimit', 'BuyStop', 'SellStop')){
        $tradeTransactionType = 'BrDelete'
    }

    rest_post -url "/api/MT4/$tradePlatformId/TradeTransaction" -data "{'tradeTransactionType':'BrClose', 'tradeCommand':'$($tr.tradeCommand)', 'orderBy':$($tr.login), 'price':$($tr.closePrice), 'symbol':'$($tr.symbol)', 'volume':$($tr.volume), 'order':$($tr.order)}"
}
#>