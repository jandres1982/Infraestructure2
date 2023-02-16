
Function Check_Azure_Server
{
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
$Interface_Az_Eu_nonProd = $ip | where {$_.IPAddress.StartsWith($Azure_Eu_nonProd)}

if ($Interface_Az_Eu_nonProd)
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

if ($Interface_Az_Eu_nonProd -or $Interface_Az_Eu_prod -or $Interface_Az_AP -or $Interface_Az_AM)
{#Write-Host "This is an Azure Server"

$Azure = $true
Return $Azure
#Config for all servers in Azure



}else
{#Write-Host "This is not an Azure Server"
$Azure = $false
Return $Azure

#Config for on-prem server

}

}


if (Check_Azure_Server)
{######### This is for Azure Servers


Function copy_Files
{
New-Item -ItemType Directory -Force "c:\TEMP\Azure\"
Copy-Item -Path ".\MMASetup-AMD64.exe" -Destination "C:\TEMP\Azure" -Force
Copy-Item -Path ".\InstallDependencyAgent-Windows.exe" -Destination "C:\TEMP\Azure" -Force
Copy-Item -Path ".\OptionalParamsPolicy" -Destination "C:\TEMP\Azure" -Force -Recurse
Copy-Item -Path ".\WindowsDefenderATPOnboardingScript.cmd" -Destination "C:\TEMP\Azure" -Force -Recurse
}


Function Defender_OS2019
{

cmd.exe /c "c:\temp\azure\WindowsDefenderATPOnboardingScript.cmd"


}


function addWorkID_Defender
{
    $workspaceId = "434c56f6-348e-429d-aede-00bb26860a0b"
    $workspaceKey = "dM1GnR5cYcmnCa77mAhAxkFT+7LcMshBDWonxpY3l14UCYYVBHDpz7yc4cUHZnmMKc9JN4p/7SQqY6f5cnVOUg=="
    $mma1 = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
    $mma1.AddCloudWorkspace($workspaceId, $workspaceKey)
    $mma1.ReloadConfiguration()
}


#function InstallNewMMA_Defender
#{
#    New-Item -ItemType Directory -Force "c:\TEMP\Azure\MMA"
#    cmd.exe /c '"C:\temp\Azure\MMASetup-AMD64.exe" /c /t:c:\TEMP\Azure\MMA'
#    cmd.exe /c 'C:\TEMP\Azure\MMA\Setup.exe /qn NOAPM=1 ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_AZURE_CLOUD_TYPE=0 OPINSIGHTS_PROXY_URL="http://webgateway-eu.schindler.com:3128" OPINSIGHTS_WORKSPACE_ID="434c56f6-348e-429d-aede-00bb26860a0b" OPINSIGHTS_WORKSPACE_KEY="dM1GnR5cYcmnCa77mAhAxkFT+7LcMshBDWonxpY3l14UCYYVBHDpz7yc4cUHZnmMKc9JN4p/7SQqY6f5cnVOUg==" AcceptEndUserLicenseAgreement=1"'
#}

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

function UpdateMMA
{
    New-Item -ItemType Directory -Force "c:\TEMP\Azure\MMA"
    cmd.exe /c '"C:\temp\Azure\MMASetup-AMD64.exe" /c /t:c:\TEMP\Azure\MMA'
    cmd.exe /c 'C:\TEMP\Azure\MMA\Setup.exe /qn /l*v c:\temp\azure\AgentUpgrade.log AcceptEndUserLicenseAgreement=1'
}          



### Main
$actualver = "10.20.18053.0"
$version = CheckMMAver($actualver)
Remove-Item -Path "c:\TEMP\Azure\MMA" -Recurse -Force -ErrorAction SilentlyContinue
Copy_files

#Checking Version for 2019

$OSVersion = (Get-WMIObject win32_operatingsystem).caption
If ($OSVersion -like '*2019*')
{
Defender_OS2019

       switch ($version)
       {
           "NO Installed"
           {
               
               #InstallNewMMA_Defender
           }
           "Greater"
           {
               
               addWorkID_Defender   
           }
           "Smaller"
           {
               
               Secure_dNET
               UpdateMMA
               sleep 10
               addWorkID_Defender
               
       	   
               
           }
           "Same"
           {
               
               addWorkID_Defender
               
           }
        }












}else
    {#not 2019 go on this switch:


       switch ($version)
       {
           "NO Installed"
           {
               
               InstallNewMMA_Defender
           }
           "Greater"
           {
               
               addWorkID_Defender   
           }
           "Smaller"
           {
               
               Secure_dNET
               UpdateMMA
               sleep 10
               addWorkID_Defender
               
       	   
               
           }
           "Same"
           {
               
               addWorkID_Defender
               
           }
        }
}


}else
    {#####################################################This is for non Azure Servers



Function Defender_OS2019
{

cmd.exe /c "c:\temp\azure\WindowsDefenderATPOnboardingScript.cmd"


}


Function copy_Files
{
New-Item -ItemType Directory -Force "c:\TEMP\Azure\"
Copy-Item -Path ".\MMASetup-AMD64.exe" -Destination "C:\TEMP\Azure" -Force
Copy-Item -Path ".\InstallDependencyAgent-Windows.exe" -Destination "C:\TEMP\Azure" -Force
Copy-Item -Path ".\OptionalParamsPolicy" -Destination "C:\TEMP\Azure" -Force -Recurse
Copy-Item -Path ".\WindowsDefenderATPOnboardingScript.cmd" -Destination "C:\TEMP\Azure" -Force -Recurse
}




function addWorkID_Defender
{
    $workspaceId = "434c56f6-348e-429d-aede-00bb26860a0b"
    $workspaceKey = "dM1GnR5cYcmnCa77mAhAxkFT+7LcMshBDWonxpY3l14UCYYVBHDpz7yc4cUHZnmMKc9JN4p/7SQqY6f5cnVOUg=="
    $mma1 = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
    $mma1.AddCloudWorkspace($workspaceId, $workspaceKey)
    $mma1.ReloadConfiguration()
}
function InstallNewMMA_Defender
{
    New-Item -ItemType Directory -Force "c:\TEMP\Azure\MMA"
    cmd.exe /c '"C:\temp\Azure\MMASetup-AMD64.exe" /c /t:c:\TEMP\Azure\MMA'
    cmd.exe /c 'C:\TEMP\Azure\MMA\Setup.exe /qn NOAPM=1 ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_AZURE_CLOUD_TYPE=0 OPINSIGHTS_PROXY_URL="http://webgateway-eu.schindler.com:3128" OPINSIGHTS_WORKSPACE_ID="434c56f6-348e-429d-aede-00bb26860a0b" OPINSIGHTS_WORKSPACE_KEY="dM1GnR5cYcmnCa77mAhAxkFT+7LcMshBDWonxpY3l14UCYYVBHDpz7yc4cUHZnmMKc9JN4p/7SQqY6f5cnVOUg==" AcceptEndUserLicenseAgreement=1"'
}

function add_proxy
{
param($ProxyDomainName="webgateway-eu.schindler.com:3128")
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
function UpdateMMA
{
    New-Item -ItemType Directory -Force "c:\TEMP\Azure\MMA"
    cmd.exe /c '"C:\temp\Azure\MMASetup-AMD64.exe" /c /t:c:\TEMP\Azure\MMA'
    cmd.exe /c 'C:\TEMP\Azure\MMA\Setup.exe /qn /l*v c:\temp\azure\AgentUpgrade.log AcceptEndUserLicenseAgreement=1'
}          
### Main
$actualver = "10.20.18053.0"
$version = CheckMMAver($actualver)
Remove-Item -Path "c:\TEMP\Azure\MMA" -Recurse -Force -ErrorAction SilentlyContinue
Copy_files

#Checking Version for 2019

$OSVersion = (Get-WMIObject win32_operatingsystem).caption
If ($OSVersion -like '*2019*')
{
Defender_OS2019
}else
    {#not 2019 go on this switch:


switch ($version)
{
    "NO Installed"
    {
        
        InstallNewMMA_Defender
    }
    "Greater"
    {
        
        addWorkID_Defender   
    }
    "Smaller"
    {
        
        Secure_dNET
        UpdateMMA
        sleep 10
        addWorkID_Defender
        add_proxy
	   
        
    }
    "Same"
    {
        
        addWorkID_Defender
        add_proxy
    }
}

     }

     
    }







    
#Function Check_OS
#{
##check_OS
#$OS_Version = (Get-WMIObject win32_operatingsystem).caption
#if ($OS_Version -like '*2019*')
#{
#Write-host "This is a 2019 Server"
#$OS_Version
#}else
#    {if ($OS_Version -like '*2016*')
#        {
#        $OS_Version
#        Write-host "This is a 2016 Server"
#        }else
#             {if ($OS_Version-like '*2012*')
#                 {
#                 $OS_Version
#                 Write-host "This is a 2012 Server"
#                 }else
#                      {if ($OS_Version -like '*2008*')
#                           {
#                            $OS_Version
#                            Write-host "This is a 2008 Server"
#                            }
#                 }
#            }
#}
#
#}
