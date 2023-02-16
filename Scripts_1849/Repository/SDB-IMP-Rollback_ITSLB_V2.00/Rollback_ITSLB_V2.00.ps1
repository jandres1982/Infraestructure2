#REQUIRES -version 3.0

<#
.SYNOPSIS
   This script rolls back ITSLB Settings to the state of November 2017, except for the Spectre/Meltdown Mitigation

.DESCRIPTION
   
   This script rolls back ITSLB Settings to the state of November 2017, except for the Spectre/Meltdown Mitigation

.OUTPUTS

   Logfiles:
       - C:\Admin\Logs\Rollback_ITSLB.Log

   ErrorCodes:
   0 - Success
   1 - There was a error during execution of script
   2 - OS is not supported
      
.INPUTS

.EXAMPLE

.LINK

.NOTES
   Author:   Ville Koch, Swisscom AG
   Version:  V02.00
   Date:     19.04.2018
   
   History:
   12.04.2018 KOVI4 initial creation
   19.04.2018 KOVI4 Excluded Spectre / Meltdown mitigation
   
#>

############################## VARIABLE section #############################

[string]$scriptPath             = Split-Path -Parent $MyInvocation.MyCommand.Definition
[string]$LogDir 				= "C:\Admin\Logs"
[string]$logfile				= "Rollback_ITSLB.Log"
[string]$LogPath 				= "$Logdir\$logfile"
# create needed Directories for Logfiles
if(!(Test-Path $LogDir)){
    try{ New-Item -ItemType directory -Path $LogDir | Out-Null }
    catch{ 
        Write-Error "Could not create Log Directory. Error details: $_.Exception.Message"
        $ErrorLevel = 2
        Exit $ErrorLevel
    }
}
############################## FUNCTIONS section #############################
Function WriteLog
# Function to write to a textfile
{
 Param (
        [Parameter(Mandatory = $true)][string]$logstring # String to log
	   )
        $datetime = [DateTime]::Now
        Add-content $LogPath -value "$datetime `t ### $logstring"
}
############################## MAIN section #############################
try {
    # Check if OS is supported
    if(([System.Environment]::OSVersion.Version.Major -ne "6") -and  ([System.Environment]::OSVersion.Version.Major -ne "10"))
    {
        Write-Error "This OS is not supported!"
        Exit 2
    }
    elseif(([System.Environment]::OSVersion.Version.Major -eq "6") -and  ([System.Environment]::OSVersion.Version.Minor -eq "1"))
    {
        # OS is Windows Server 2008 R2

        <#region section Spectre
            $Path = 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'
            if (Test-path -path $Path)
            {
                $MemoryManagement = Get-ItemProperty -Path $Path
                if($MemoryManagement.FeatureSettingsOverride){ 
                    Remove-ItemProperty -Path $Path -Name FeatureSettingsOverride
                    $logstring = "[INFO] deleted RegKey FeatureSettingsOverride"
                    WriteLog $logstring
                }
                if($MemoryManagement.FeatureSettingsOverrideMask){ 
                    Remove-ItemProperty -Path $Path -Name FeatureSettingsOverrideMask
                    $logstring = "[INFO] deleted RegKey FeatureSettingsOverrideMask"
                    WriteLog $logstring
                }
            }
        #endregion#>
    }
    elseif(([System.Environment]::OSVersion.Version.Major -eq "6") -and  ([System.Environment]::OSVersion.Version.Minor -eq "2"))
    {
        # OS is Windows Server 2012
        <#region section Spectre
            $Path = 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'
            if (Test-path -path $Path)
            {
                $MemoryManagement = Get-ItemProperty -Path $Path
                if($MemoryManagement.FeatureSettingsOverride){ 
                    Remove-ItemProperty -Path $Path -Name FeatureSettingsOverride
                    $logstring = "[INFO] deleted RegKey FeatureSettingsOverride"
                    WriteLog $logstring
                }
                if($MemoryManagement.FeatureSettingsOverrideMask){ 
                    Remove-ItemProperty -Path $Path -Name FeatureSettingsOverrideMask
                    $logstring = "[INFO] deleted RegKey FeatureSettingsOverrideMask"
                    WriteLog $logstring
                }
            }
        #endregion#>
        $Path = 'Registry::HKLM\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\PKCS'
        if (Test-path -path $Path)
        {
            $PKCS = Get-ItemProperty -Path $Path
            if($PKCS.ClientMinKeyBitLength){ 
                Remove-ItemProperty -Path $Path -Name ClientMinKeyBitLength
                $logstring = "[INFO] deleted RegKey ClientMinKeyBitLength"
                WriteLog $logstring
            }
        }
        $Path = 'Registry::HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters'
        if (Test-path -path $Path)
        {
            $Kerberos = Get-ItemProperty -Path $Path
            if($Kerberos.SupportedEncryptionTypes){ 
                Set-ItemProperty -Path $Path -Name SupportedEncryptionTypes -Value '2147483644'
                $logstring = "[INFO] Changed Value of RegKey SupportedEncryptionTypes to 2147483644"
                WriteLog $logstring
            }
        }
        $Path = 'Registry::HKLM\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002'
        $newvalue = "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_DHE_RSA_WITH_AES_256_GCM_SHA384,TLS_DHE_DSS_WITH_AES_256_GCM_SHA384,TLS_DHE_RSA_WITH_AES_128_GCM_SHA256,TLS_DHE_DSS_WITH_AES_128_GCM_SHA256,TLS_DHE_RSA_WITH_CAMELLIA_256_GCM_SHA384,TLS_DHE_DSS_WITH_CAMELLIA_256_GCM_SHA256,TLS_DHE_RSA_WITH_CAMELLIA_128_GCM_SHA256,TLS_DHE_DSS_WITH_CAMELLIA_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_CCM,TLS_ECDHE_ECDSA_WITH_AES_256_CCM_8,TLS_DHE_RSA_WITH_AES_256_CCM,TLS_DHE_RSA_WITH_AES_256_CCM_8,TLS_ECDHE_ECDSA_WITH_AES_128_CCM,TLS_ECDHE_ECDSA_WITH_AES_128_CCM_8,TLS_DHE_RSA_WITH_AES_128_CCM,TLS_DHE_RSA_WITH_AES_128_CCM_8,TLS_RSA_WITH_AES_256_CBC_SHA256"
        if (Test-path -path $Path)
        {
            $CipherSuites = Get-ItemProperty -Path $Path
            if($CipherSuites.Functions){ 
                $functions = Get-ItemProperty -Path $Path -Name Functions
                if($functions.Functions -like $newvalue){
                    Set-ItemProperty -Path $Path -Name Functions -Value 'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_DHE_RSA_WITH_AES_256_GCM_SHA384,TLS_DHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_RSA_WITH_AES_256_CBC_SHA,TLS_DHE_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_128_GCM_SHA256,TLS_RSA_WITH_AES_256_CBC_SHA256,TLS_RSA_WITH_AES_128_CBC_SHA256,TLS_RSA_WITH_AES_256_CBC_SHA,TLS_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_DSS_WITH_AES_256_CBC_SHA256,TLS_DHE_DSS_WITH_AES_128_CBC_SHA256,TLS_DHE_DSS_WITH_AES_256_CBC_SHA,TLS_DHE_DSS_WITH_AES_128_CBC_SHA'
                    $logstring = "[INFO] Changed Value of RegKey Functions to TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_DHE_RSA_WITH_AES_256_GCM_SHA384,TLS_DHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_RSA_WITH_AES_256_CBC_SHA,TLS_DHE_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_128_GCM_SHA256,TLS_RSA_WITH_AES_256_CBC_SHA256,TLS_RSA_WITH_AES_128_CBC_SHA256,TLS_RSA_WITH_AES_256_CBC_SHA,TLS_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_DSS_WITH_AES_256_CBC_SHA256,TLS_DHE_DSS_WITH_AES_128_CBC_SHA256,TLS_DHE_DSS_WITH_AES_256_CBC_SHA,TLS_DHE_DSS_WITH_AES_128_CBC_SHA"
                    WriteLog $logstring
                }else{
                    $logstring = "[INFO] No changes on RegKey Functions because value was not from new ITSLB!"
                    WriteLog $logstring
                }
            }
        }
    }
    elseif(([System.Environment]::OSVersion.Version.Major -eq "6") -and  ([System.Environment]::OSVersion.Version.Minor -eq "3"))
    {
        # OS is Windows Server 2012 R2
        <#region section Spectre
            $Path = 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'
            if (Test-path -path $Path)
            {
                $MemoryManagement = Get-ItemProperty -Path $Path
                if($MemoryManagement.FeatureSettingsOverride){ 
                    Remove-ItemProperty -Path $Path -Name FeatureSettingsOverride
                    $logstring = "[INFO] deleted RegKey FeatureSettingsOverride"
                    WriteLog $logstring
                }
                if($MemoryManagement.FeatureSettingsOverrideMask){ 
                    Remove-ItemProperty -Path $Path -Name FeatureSettingsOverrideMask
                    $logstring = "[INFO] deleted RegKey FeatureSettingsOverrideMask"
                    WriteLog $logstring
                }
            }
        #endregion#>
        $Path = 'Registry::HKLM\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\PKCS'
        if (Test-path -path $Path)
        {
            $PKCS = Get-ItemProperty -Path $Path
            if($PKCS.ClientMinKeyBitLength){ 
                Remove-ItemProperty -Path $Path -Name ClientMinKeyBitLength
                $logstring = "[INFO] deleted RegKey ClientMinKeyBitLength"
                WriteLog $logstring
            }
        }
        $Path = 'Registry::HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters'
        if (Test-path -path $Path)
        {
            $Kerberos = Get-ItemProperty -Path $Path
            if($Kerberos.SupportedEncryptionTypes){ 
                Set-ItemProperty -Path $Path -Name SupportedEncryptionTypes -Value '2147483644'
                $logstring = "[INFO] Changed Value of RegKey SupportedEncryptionTypes to 2147483644"
                WriteLog $logstring
            }
        }
        $Path = 'Registry::HKLM\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002'
        $newvalue = "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_DHE_RSA_WITH_AES_256_GCM_SHA384,TLS_DHE_DSS_WITH_AES_256_GCM_SHA384,TLS_DHE_RSA_WITH_AES_128_GCM_SHA256,TLS_DHE_DSS_WITH_AES_128_GCM_SHA256,TLS_DHE_RSA_WITH_CAMELLIA_256_GCM_SHA384,TLS_DHE_DSS_WITH_CAMELLIA_256_GCM_SHA256,TLS_DHE_RSA_WITH_CAMELLIA_128_GCM_SHA256,TLS_DHE_DSS_WITH_CAMELLIA_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_CCM,TLS_ECDHE_ECDSA_WITH_AES_256_CCM_8,TLS_DHE_RSA_WITH_AES_256_CCM,TLS_DHE_RSA_WITH_AES_256_CCM_8,TLS_ECDHE_ECDSA_WITH_AES_128_CCM,TLS_ECDHE_ECDSA_WITH_AES_128_CCM_8,TLS_DHE_RSA_WITH_AES_128_CCM,TLS_DHE_RSA_WITH_AES_128_CCM_8,TLS_RSA_WITH_AES_256_CBC_SHA256"
        if (Test-path -path $Path)
        {
            $CipherSuites = Get-ItemProperty -Path $Path
            if($CipherSuites.Functions){ 
                $functions = Get-ItemProperty -Path $Path -Name Functions
                if($functions.Functions -like $newvalue){
                    Set-ItemProperty -Path $Path -Name Functions -Value 'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_DHE_RSA_WITH_AES_256_GCM_SHA384,TLS_DHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_RSA_WITH_AES_256_CBC_SHA,TLS_DHE_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_128_GCM_SHA256,TLS_RSA_WITH_AES_256_CBC_SHA256,TLS_RSA_WITH_AES_128_CBC_SHA256,TLS_RSA_WITH_AES_256_CBC_SHA,TLS_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_DSS_WITH_AES_256_CBC_SHA256,TLS_DHE_DSS_WITH_AES_128_CBC_SHA256,TLS_DHE_DSS_WITH_AES_256_CBC_SHA,TLS_DHE_DSS_WITH_AES_128_CBC_SHA'
                    $logstring = "[INFO] Changed Value of RegKey Functions to TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_DHE_RSA_WITH_AES_256_GCM_SHA384,TLS_DHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_RSA_WITH_AES_256_CBC_SHA,TLS_DHE_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_128_GCM_SHA256,TLS_RSA_WITH_AES_256_CBC_SHA256,TLS_RSA_WITH_AES_128_CBC_SHA256,TLS_RSA_WITH_AES_256_CBC_SHA,TLS_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_DSS_WITH_AES_256_CBC_SHA256,TLS_DHE_DSS_WITH_AES_128_CBC_SHA256,TLS_DHE_DSS_WITH_AES_256_CBC_SHA,TLS_DHE_DSS_WITH_AES_128_CBC_SHA"
                    WriteLog $logstring
                }else{
                    $logstring = "[INFO] No changes on RegKey Functions because value was not from new ITSLB!"
                    WriteLog $logstring
                }
            }
        }
    }
    elseif(([System.Environment]::OSVersion.Version.Major -eq "10") -and  ([System.Environment]::OSVersion.Version.Minor -eq "0"))
    {
        # OS is Windows Server 2016
        <#region section Spectre
            $Path = 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'
            if (Test-path -path $Path)
            {
                $MemoryManagement = Get-ItemProperty -Path $Path
                if($MemoryManagement.FeatureSettingsOverride){ 
                    Remove-ItemProperty -Path $Path -Name FeatureSettingsOverride
                    $logstring = "[INFO] deleted RegKey FeatureSettingsOverride"
                    WriteLog $logstring
                }
                if($MemoryManagement.FeatureSettingsOverrideMask){ 
                    Remove-ItemProperty -Path $Path -Name FeatureSettingsOverrideMask
                    $logstring = "[INFO] deleted RegKey FeatureSettingsOverrideMask"
                    WriteLog $logstring
                }
            }
        #endregion#>
        $Path = 'Registry::HKLM\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\PKCS'
        if (Test-path -path $Path)
        {
            $PKCS = Get-ItemProperty -Path $Path
            if($PKCS.ClientMinKeyBitLength){ 
                Remove-ItemProperty -Path $Path -Name ClientMinKeyBitLength
                $logstring = "[INFO] deleted RegKey ClientMinKeyBitLength"
                WriteLog $logstring
            }
        }
        $Path = 'Registry::HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters'
        if (Test-path -path $Path)
        {
            $Kerberos = Get-ItemProperty -Path $Path
            if($Kerberos.SupportedEncryptionTypes){ 
                Set-ItemProperty -Path $Path -Name SupportedEncryptionTypes -Value '2147483644'
                $logstring = "[INFO] Changed Value of RegKey SupportedEncryptionTypes to 2147483644"
                WriteLog $logstring
            }
        }
        $Path = 'Registry::HKLM\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002'
        $newvalue = "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_DHE_RSA_WITH_AES_256_GCM_SHA384,TLS_DHE_DSS_WITH_AES_256_GCM_SHA384,TLS_DHE_RSA_WITH_AES_128_GCM_SHA256,TLS_DHE_DSS_WITH_AES_128_GCM_SHA256,TLS_DHE_RSA_WITH_CAMELLIA_256_GCM_SHA384,TLS_DHE_DSS_WITH_CAMELLIA_256_GCM_SHA256,TLS_DHE_RSA_WITH_CAMELLIA_128_GCM_SHA256,TLS_DHE_DSS_WITH_CAMELLIA_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_CCM,TLS_ECDHE_ECDSA_WITH_AES_256_CCM_8,TLS_DHE_RSA_WITH_AES_256_CCM,TLS_DHE_RSA_WITH_AES_256_CCM_8,TLS_ECDHE_ECDSA_WITH_AES_128_CCM,TLS_ECDHE_ECDSA_WITH_AES_128_CCM_8,TLS_DHE_RSA_WITH_AES_128_CCM,TLS_DHE_RSA_WITH_AES_128_CCM_8,TLS_RSA_WITH_AES_256_CBC_SHA256"
        if (Test-path -path $Path)
        {
            $CipherSuites = Get-ItemProperty -Path $Path
            if($CipherSuites.Functions){ 
                $functions = Get-ItemProperty -Path $Path -Name Functions
                if($functions.Functions -like $newvalue){
                    Set-ItemProperty -Path $Path -Name Functions -Value 'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_DHE_RSA_WITH_AES_256_GCM_SHA384,TLS_DHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_RSA_WITH_AES_256_CBC_SHA,TLS_DHE_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_128_GCM_SHA256,TLS_RSA_WITH_AES_256_CBC_SHA256,TLS_RSA_WITH_AES_128_CBC_SHA256,TLS_RSA_WITH_AES_256_CBC_SHA,TLS_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_DSS_WITH_AES_256_CBC_SHA256,TLS_DHE_DSS_WITH_AES_128_CBC_SHA256,TLS_DHE_DSS_WITH_AES_256_CBC_SHA,TLS_DHE_DSS_WITH_AES_128_CBC_SHA'
                    $logstring = "[INFO] Changed Value of RegKey Functions to TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_DHE_RSA_WITH_AES_256_GCM_SHA384,TLS_DHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_RSA_WITH_AES_256_CBC_SHA,TLS_DHE_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_128_GCM_SHA256,TLS_RSA_WITH_AES_256_CBC_SHA256,TLS_RSA_WITH_AES_128_CBC_SHA256,TLS_RSA_WITH_AES_256_CBC_SHA,TLS_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_DSS_WITH_AES_256_CBC_SHA256,TLS_DHE_DSS_WITH_AES_128_CBC_SHA256,TLS_DHE_DSS_WITH_AES_256_CBC_SHA,TLS_DHE_DSS_WITH_AES_128_CBC_SHA"
                    WriteLog $logstring
                }else{
                    $logstring = "[INFO] No changes on RegKey Functions because value was not from new ITSLB!"
                    WriteLog $logstring
                }
            }
        }
    }
    else
    {
        Write-Error "This OS is not supported!"
        Exit 2
    }

}
catch {
    # error...
    $logstring = "[ERROR] There was an error when running the script. Error details: $_.Exception.Message"
    WriteLog $logstring
    Exit 1
}
