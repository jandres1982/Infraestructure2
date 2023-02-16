# Migration MMA Script

###
### Functions
###

# Check MMA Version
function CheckMMAver
{
    param([string]$actualver)
    $ver = "NO Installed"
    $mmaversion = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup" -ErrorAction SilentlyContinue
    $agentver = $mmaversion.AgentVersion
    if ($agentver -is [string])
    {
        $verarray= $agentver.Split(".")
        $actualverarray=$actualver.Split(".")
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
     }
     return ($ver)
}

function addWorkID_Migration
{
    $workspaceId = "a054b1bf-24eb-4e0b-a7e6-0fb782e77bf6"
    $workspaceKey = "d/DAXhGLEcj+D+QNvTQj84jWCEcAb+jsn/37lroX0zjfBEQBIOppTeIglpqCeCHz6a/XXcyY8QgUvmrOkV+dmg=="
    $mma1 = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
    $mma1.AddCloudWorkspace($workspaceId, $workspaceKey)
    $mma1.ReloadConfiguration()
}

# Function Install new MMA - WorkID MIG
function InstallNewMMA_MIG
{
    New-Item -ItemType Directory -Force "c:\TEMP\Azure\MMA"
    cmd.exe /c '"MMASetup-AMD64.exe" /c /t:c:\TEMP\Azure\MMA'
    cmd.exe /c 'C:\TEMP\Azure\MMA\Setup.exe /qn NOAPM=1 ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_AZURE_CLOUD_TYPE=0 OPINSIGHTS_PROXY_URL="http://webgateway-eu.schindler.com:3128" OPINSIGHTS_WORKSPACE_ID="a054b1bf-24eb-4e0b-a7e6-0fb782e77bf6" OPINSIGHTS_WORKSPACE_KEY="d/DAXhGLEcj+D+QNvTQj84jWCEcAb+jsn/37lroX0zjfBEQBIOppTeIglpqCeCHz6a/XXcyY8QgUvmrOkV+dmg==" AcceptEndUserLicenseAgreement=1"'
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
    $healthServiceSettings.SetProxyInfo($ProxyDomainName, "", "")
}

# Function Update MMA
function UpdateMMA
{
    New-Item -ItemType Directory -Force "c:\TEMP\Azure\MMA"
    cmd.exe /c '"MMASetup-AMD64.exe" /c /t:c:\TEMP\Azure\MMA'
    cmd.exe /c 'C:\TEMP\Azure\MMA\Setup.exe /qn /l*v c:\temp\azure\AgentUpgrade.log AcceptEndUserLicenseAgreement=1'
}          


###
### Main
###

$actualver = "10.20.18053.0"
$version = CheckMMAver($actualver)
switch ($version)
{
    "NO Installed"
    {
        InstallNewMMA_MIG
    }
    "Greater"
    {
        addWorkID_Migration
    }
    "Smaller"
    {
        Secure_dNET
        UpdateMMA
        addWorkID_Migration
        addProxy

    }
    "Same"
    {
        addWorkID_Migration
    }
}
 