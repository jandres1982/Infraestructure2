# MMA iScript

###
### Functions
###


# Check Azure
function IsAzure
{
    $Azure_Eu_Prod = '10.38'
    $Azure_Eu_Prod_1 = '10.39'
    $Azure_Eu_nonProd = '10.37'
    $Azure_AP = '10.87'
    $Azure_AM_Prod = '10.165'
    $Azure_AM_nonProd = '10.166'
    $ip = Get-NetIPAddress
    $Azure = "AZURE"

    $Interface_Az_Eu_prod = $ip | where {$_.IPAddress.StartsWith($Azure_Eu_Prod) -or $_.IPAddress.StartsWith($Azure_Eu_Prod_1)}
    if ($Interface_Az_Eu_prod)
    {
        $subs = "505ead1a-5a5f-4363-9b72-83eb2234a43d"
    }
    $Interface_Az_Eu_nonProd = $ip | where {$_.IPAddress.StartsWith($Azure_Eu_nonProd)}
    if ($Interface_Az_Eu_nonProd)
    {
        $subs = "7fa3c3a2-7d0d-4987-a30c-30623e38756c"
    }
    $Interface_Az_AP = $ip | where {$_.IPAddress.StartsWith($Azure_AP)}
    if ($Interface_Az_AP)
    {
        $subs = "59c20947-4965-45c4-99f3-12be96106119"
    }
    $Interface_Az_AM = $ip | where {$_.IPAddress.StartsWith($Azure_AM_Prod)}
    if ($Interface_Az_AM)
    {
        $subs = "e03c610e-a71c-4518-a4a3-8ce128fca34d"
    }
    $Azure_AM_Prod = $ip | where {$_.IPAddress.StartsWith($Azure_AM_nonProd)}
    if ($Interface_Az_AM)
    {
        $subs = "8528129a-0394-4057-ac4e-0fec3da2246d"
    }
    if ($Interface_Az_Eu_nonProd -or $Interface_Az_Eu_prod -or $Interface_Az_AP -or $Interface_Az_AM){}
    else
    {
        $Azure = "NO AZURE"
        Select-AzSubscription $subs
     }
    return $Azure
}

# Check MMA Version
function CheckMMAver
{
    param([string]$actualver)
    $mmaversion = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup" -ErrorAction SilentlyContinue
    $agentver = $mmaversion.AgentVersion
    $verarray= $agentver.Split(".")
    $actualverarray=$actualver.Split(".")
    $ver = "NO Installed"
    for($index = 0; $index -lt $verarray.count; $index++)
    {
        $version = [int]$verarray[$index]
        $actualversion = [int]$actualverarray[$index]
        if ($version -gt $actualversion)
        {
            $ver = "Greater"
            break
        }
        if ($version -lt $actualversion)
        {
            $ver = "Smaller"
            break
        }
         if ($version -eq $actualversion)
        {
            $ver = "Same"
        }
     }
     return ($ver)
}


# Function Proxy configuration
function addProxy
{
    $ProxyDomainName="webgateway-eu.schindler.com:3128"
    $healthServiceSettings = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
    $proxyMethod = $healthServiceSettings | Get-Member -Name 'SetProxyInfo'
    if ($healthServiceSettings.proxyUrl -ne $ProxyDomainName)
    {
        $ProxyDomainName = $healthServiceSettings.proxyUrl
    }
    $healthServiceSettings.SetProxyInfo('', '', '')
    $healthServiceSettings.SetProxyInfo($ProxyDomainName,'','')
}


# Function Workspace configuration
function addWorkID_SCC
{
    $workspaceId = "fa488d5a-d8e4-4437-9ccc-2ef59e9eb669"
    $workspaceKey = "1DxbXeHBAM3QLWl4GcE9SF0eTCEYuyr5pAt5k3wGG+bASH/ug9XGmVUyHKGvi/nmVIAYLLvfemwkuhM0yxGWCA=="
    $mma1 = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
    $mma1.AddCloudWorkspace($workspaceId, $workspaceKey)
    $mma1.ReloadConfiguration()
}

function addWorkID_Migration
{
    $workspaceId = "a054b1bf-24eb-4e0b-a7e6-0fb782e77bf6"
    $workspaceKey = "d/DAXhGLEcj+D+QNvTQj84jWCEcAb+jsn/37lroX0zjfBEQBIOppTeIglpqCeCHz6a/XXcyY8QgUvmrOkV+dmg=="
    $mma1 = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
    $mma1.AddCloudWorkspace($workspaceId, $workspaceKey)
    $mma1.ReloadConfiguration()
}

function addWorkID_SoC
{
    $workspaceId = "b615f112-4439-41fa-aa80-424be76d309e"
    $workspaceKey = "xO/JqiWFSYxGY7uIe1XgeFE3LjWFq8jvxoYyLcSGiHNkR/GnDG7eDd1WijUwMD7fW2y8rUnyLeVM8U1s9sDoqQ=="
    $mma1 = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
    $mma1.AddCloudWorkspace($workspaceId, $workspaceKey)
    $mma1.ReloadConfiguration()
}


# Function Install new MMA - WorkID SCC
function InstallNewMMA
{
    New-Item -ItemType Directory -Force "c:\TEMP\Azure\MMA"
    cmd.exe /c '"C:\Program Files (x86)\LANDesk\LDClient\sdmcache\ldsource$\Packages_V2\Schindler\AzureMigration\MMASetup-AMD64.exe" /c /t:c:\TEMP\Azure\MMA'
    cmd.exe /c 'C:\TEMP\Azure\MMA\Setup.exe /qn NOAPM=1 ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_AZURE_CLOUD_TYPE=0 OPINSIGHTS_PROXY_URL="http://webgateway-eu.schindler.com:3128" OPINSIGHTS_WORKSPACE_ID="fa488d5a-d8e4-4437-9ccc-2ef59e9eb669" OPINSIGHTS_WORKSPACE_KEY="1DxbXeHBAM3QLWl4GcE9SF0eTCEYuyr5pAt5k3wGG+bASH/ug9XGmVUyHKGvi/nmVIAYLLvfemwkuhM0yxGWCA==" AcceptEndUserLicenseAgreement=1"'
}

# Function Install new MMA - WorkID MIG
function InstallNewMMA_MIG
{
    New-Item -ItemType Directory -Force "c:\TEMP\Azure\MMA"
    cmd.exe /c '"C:\Program Files (x86)\LANDesk\LDClient\sdmcache\ldsource$\Packages_V2\Schindler\AzureMigration\MMASetup-AMD64.exe" /c /t:c:\TEMP\Azure\MMA'
    cmd.exe /c 'C:\TEMP\Azure\MMA\Setup.exe /qn NOAPM=1 ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_AZURE_CLOUD_TYPE=0 OPINSIGHTS_PROXY_URL="http://webgateway-eu.schindler.com:3128" OPINSIGHTS_WORKSPACE_ID="a054b1bf-24eb-4e0b-a7e6-0fb782e77bf6" OPINSIGHTS_WORKSPACE_KEY="d/DAXhGLEcj+D+QNvTQj84jWCEcAb+jsn/37lroX0zjfBEQBIOppTeIglpqCeCHz6a/XXcyY8QgUvmrOkV+dmg==" AcceptEndUserLicenseAgreement=1"'
}

# Function Install Az extension MMA
function InstallExtMMA
{
    $vm = Get-AzVM
    $azhostname = $vm.Name
    $azrg = $vm.ResourceGroupName
    az vm extension set -n MicrosoftMonitoringAgent --publisher Microsoft.EnterpriseCloud.Monitoring --version 1.0.18053.0 --vm-name $azhostname --resource-group $azrg
}


#Function Secure .Net
function Secure_dNET
{
    if (Get-ItemProperty -path HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319)
    {
        cmd.exe /c "REG ADD HKLM\SOFTWARE\Microsoft\.NETFramework\v4.0.30319 /v SchUseStrongCrypto /t REG_DWORD /d 1 /f"
        New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -Name SchUseStrongCrypto -PropertyType DWORD -Value 1 -ErrorAction SilentlyContinue
    }
    if (Get-ItemProperty -path HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319)
    {
        cmd.exe /c "REG ADD HKLM\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319 /v SchUseStrongCrypto /t REG_DWORD /d 1 /f" 
        New-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319' -Name SchUseStrongCrypto -PropertyType DWORD -Value 1 -ErrorAction SilentlyContinue
    }
}


# Function Update MMA
function UpdateMMA
{
    New-Item -ItemType Directory -Force "c:\TEMP\Azure\MMA"
    cmd.exe /c '"C:\Program Files (x86)\LANDesk\LDClient\sdmcache\ldsource$\Packages_V2\Schindler\AzureMigration\MMASetup-AMD64.exe" /c /t:c:\TEMP\Azure\MMA'
    cmd.exe /c 'C:\TEMP\Azure\MMA\Setup.exe /qn /l*v c:\temp\azure\AgentUpgrade.log AcceptEndUserLicenseAgreement=1'
}          


###
### Main
###

$actualver = "10.20.18053.0"

$azure = IsAzure
$version = CheckMMAver($actualver)
if ($azure -eq "NO AZURE")
{
    switch ($version)
    {
        "NO Installed"
        {
            #InstallNewMMA
            InstallNewMMA_MIG
            #addWorkID_SoC
        }
        "Greater"
        {
            #addProxy
            #addWorkID_SSC
            #addWorkID_SoC
            addWorkID_Migration
        }
        "Smaller"
        {
            Secure_dNET
            UpdateMMA
            #addProxy
            #addWorkID_SSC
            #addWorkID_SoC
            addWorkID_Migration
        }
    }
}
else
{
    if ($version -eq "NO Installed")
    {
        InstallExtMMA
    }
    #addWorkID_SSC
    #addWorkID_SoC
}
 