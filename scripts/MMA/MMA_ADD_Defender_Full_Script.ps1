# Migration MMA Script
$server_list = gc "D:\Repository\Working\Antonio\MMA\Server_List.txt"
$destination = "c$\temp" 



###
### Functions
###

Foreach ($Server in $server_list)
{
$Result = invoke-command -ComputerName $server -ScriptBlock {
# Check MMA Version

function install_dependency_agent
{
    $server = hostname
If (Test-Path -Path "C:\temp\azure\InstallDependencyAgent-Windows.exe" -ErrorAction SilentlyContinue)
            {
            cmd.exe /c 'C:\temp\Azure\InstallDependencyAgent-windows.exe /S /RebootMode=Manual'
            If (Get-Service -Name MicrosoftDependencyAgent -ErrorAction SilentlyContinue)
              {
                Write-host "$Server, Dependency Agent Installed" -ForegroundColor Green
            }
            else
            {
                Write-host "$Server, Dependency Agent Failed" -ForegroundColor Yellow
            }
}else
{
    Write-host "$Server, Dependency Agent File not found" -ForegroundColor Yellow
}
}


function add_proxy
{
param($ProxyDomainName="webgateway-eu.schindler.com:3128")

# First we get the Health Service configuration object.  We need to determine if we
# have the right update rollup with the API we need.  If not, no need to run the rest of the script.
$healthServiceSettings = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'

$proxyMethod = $healthServiceSettings | Get-Member -Name 'SetProxyInfo'

if (!$proxyMethod)
{
    Write-Output 'Health Service proxy API not present, will not update settings.'
    return
}

Write-Output "Clearing proxy settings."
$healthServiceSettings.SetProxyInfo('', '', '')

Write-Output "Setting proxy to $ProxyDomainName"
$healthServiceSettings.SetProxyInfo($ProxyDomainName, "","")

}



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



function addWorkID_Defender
{
    $workspaceId = "434c56f6-348e-429d-aede-00bb26860a0b"
    $workspaceKey = "dM1GnR5cYcmnCa77mAhAxkFT+7LcMshBDWonxpY3l14UCYYVBHDpz7yc4cUHZnmMKc9JN4p/7SQqY6f5cnVOUg=="
    $mma1 = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
    $mma1.AddCloudWorkspace($workspaceId, $workspaceKey)
    $mma1.ReloadConfiguration()
}



# Function Install new MMA - WorkID MIG
function InstallNewMMA_MIG
{
    New-Item -ItemType Directory -Force "c:\TEMP\Azure\MMA"
    cmd.exe /c '"C:\temp\Azure\MMASetup-AMD64.exe" /c /t:c:\TEMP\Azure\MMA'
    cmd.exe /c 'C:\TEMP\Azure\MMA\Setup.exe /qn NOAPM=1 ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_AZURE_CLOUD_TYPE=0 OPINSIGHTS_PROXY_URL="http://webgateway-eu.schindler.com:3128" OPINSIGHTS_WORKSPACE_ID="a054b1bf-24eb-4e0b-a7e6-0fb782e77bf6" OPINSIGHTS_WORKSPACE_KEY="d/DAXhGLEcj+D+QNvTQj84jWCEcAb+jsn/37lroX0zjfBEQBIOppTeIglpqCeCHz6a/XXcyY8QgUvmrOkV+dmg==" AcceptEndUserLicenseAgreement=1"'
}


function InstallNewMMA_Defender
{
    New-Item -ItemType Directory -Force "c:\TEMP\Azure\MMA"
    cmd.exe /c '"C:\temp\Azure\MMASetup-AMD64.exe" /c /t:c:\TEMP\Azure\MMA'
    cmd.exe /c 'C:\TEMP\Azure\MMA\Setup.exe /qn NOAPM=1 ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_AZURE_CLOUD_TYPE=0 OPINSIGHTS_PROXY_URL="http://webgateway-eu.schindler.com:3128" OPINSIGHTS_WORKSPACE_ID="434c56f6-348e-429d-aede-00bb26860a0b" OPINSIGHTS_WORKSPACE_KEY="dM1GnR5cYcmnCa77mAhAxkFT+7LcMshBDWonxpY3l14UCYYVBHDpz7yc4cUHZnmMKc9JN4p/7SQqY6f5cnVOUg==" AcceptEndUserLicenseAgreement=1"'
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
    cmd.exe /c '"C:\temp\Azure\MMASetup-AMD64.exe" /c /t:c:\TEMP\Azure\MMA'
    cmd.exe /c 'C:\TEMP\Azure\MMA\Setup.exe /qn /l*v c:\temp\azure\AgentUpgrade.log AcceptEndUserLicenseAgreement=1'
}          


###
### Main
###

$actualver = "10.20.18053.0"
$version = CheckMMAver($actualver)
Remove-Item -Path "c:\TEMP\Azure\MMA" -Recurse -Force -ErrorAction SilentlyContinue
$actualver
$version
switch ($version)
{
    "NO Installed"
    {
        InstallNewMMA_Defender
        #InstallNewMMA_MIG
        #install_dependency_agent
    }
    "Greater"
    {
        #addWorkID_Migration
        addWorkID_Defender
        #install_dependency_agent
    }
    "Smaller"
    {
        Secure_dNET
        UpdateMMA
        sleep 10
        #addWorkID_Migration
        addWorkID_Defender
        add_proxy
        #install_dependency_agent
        
    }
    "Same"
    {
        #addWorkID_Migration
        addWorkID_Defender
        add_proxy
        #install_dependency_agent
    }
}
 
 }
 Write-Output "$Server, completed" >> "D:\Repository\Working\Antonio\MMA\Logs\Result_MMA.txt"
 Write-output "$Server"

 $Result
 }