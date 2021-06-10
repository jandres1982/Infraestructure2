###########################################################################################
######################### Defining Azure EU prod Servers ##################################
$Azure_Eu_Prod = '10.38'
$Azure_Eu_Prod_1 = '10.39'
$ip = Get-NetIPAddress
$Interface_Az_Eu_prod = $ip | where {$_.IPAddress.StartsWith($Azure_Eu_Prod) -or $_.IPAddress.StartsWith($Azure_Eu_Prod_1)}

if ($Interface_Az_Eu_prod)
{Write-host "This is an Azure EU prod Server"


###### Isert config for Az EU prod Servers


}


#**********************************************************************************************

###############################################################################################
######################### Defining Azure EU non prod Servers ##################################
$Azure_Eu_nonProd = '10.37'

$ip = Get-NetIPAddress
$Interface_Az_EU_nonProd = $ip | where {$_.IPAddress.StartsWith($Azure_Eu_nonProd)}

if ($Interface_Az_EU_nonProd)
{Write-host "This is an Azure EU non prod Server"


###### Isert config for Az EU non prod Servers


}

#**********************************************************************************************

######################################################################################
######################### Defining Azure AP Servers ##################################
$Azure_AP = '10.87'

$ip = Get-NetIPAddress
$Interface_Az_AP = $ip | where {$_.IPAddress.StartsWith($Azure_AP)}

if ($Interface_Az_AP)
{Write-host "This is an Azure AP Server"


###### Isert config for Az AP Servers


}

#**********************************************************************************************


######################################################################################
######################### Defining Azure AM Servers ##################################
$Azure_AM_Prod = '10.165'
$Azure_AM_nonProd = '10.166'
$ip = Get-NetIPAddress
$Interface_Az_AM = $ip | where {$_.IPAddress.StartsWith($Azure_AM_Prod) -or $_.IPAddress.StartsWith($Azure_AM_nonProd)}

if ($Interface_Az_AM)
{Write-host "This is an Azure AM Server"


###### Isert config for Az AP Servers


}

#**********************************************************************************************

