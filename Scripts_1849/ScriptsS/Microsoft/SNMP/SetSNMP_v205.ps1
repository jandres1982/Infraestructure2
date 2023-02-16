#=============================================================================#
#                                                                             #
# SetSNMP.ps1                                                                 #
# Powershell Script to set default SNMP settings                              #
# Existing Permitted Managerers and Trap Destinations will not be overwritten #
# Author: Erich Niffeler                                                      #
# Creation Date: 27.08.2014                                                   #
# Modified Date: 14.01.2015                                                   #
# Version: 02.00.05                                                           #
#                                                                             #
# Example: C:\Temp\SetSNMP.ps1 -sysLocation "sysloc" -sysContact "syscontact" #
#                                                                             #
# if no paramter are set the default location and syscontact will be set.     #
# Default: sysLocation = "Ebikon, DC1",                                       #
#          sysContact = "M_INF_DC_SCC@ch.schindler.com"                       #
# Return Codes: O=successful, 1=error                                         #
#                                                                             #
#=============================================================================#

[CmdletBinding()]
Param(
  [Parameter(Mandatory=$False,Position=1)]
   [string]$sysLocation = "Ebikon, DC1",
	
   [Parameter(Mandatory=$False)]
   [string]$sysContact = "M_INF_DC_SCC@ch.schindler.com"
)

    $TDestination = @()
    $PManager = @()
    $DefaultTD = @("shhscpicingamon01.global.schindler.com")
    $DefaultPM = @("localhost","shhscpicingamon01.global.schindler.com","shhscpirsprod.global.schindler.com")
    $DeleteTD = @("manage1.global.schindler.com","manage2.global.schindler.com","manage4.global.schindler.com","shhscpwugmon02.global.schindler.com")
    $DeletePM = @("manage1.global.schindler.com","manage2.global.schindler.com","manage3.global.schindler.com","manage4.global.schindler.com","manage5.global.schindler.com","monitor.schindler.com","shhscpwugmon01.global.schindler.com","shhscpwugmon02.global.schindler.com","shhscpwugmon04.global.schindler.com")


    try {

        #Check if Server is a VMWARE or a Hardware Platform
        #For HW Patform add IRS as Trap Destination
        $cs = Get-WmiObject -class Win32_ComputerSystem
        if ($cs.Manufacturer -notlike "VMWARE*"){
            $DefaultTD += "shhscpirsprod.global.schindler.com"
        }

        #Check if SNMP Feature is installed
        Import-Module ServerManager
        if ((Get-WindowsFeature -name "SNMP-Services").installed -ne $True) {
            #Install/Enable SNMP Services
            Add-WindowsFeature SNMP-Services | Out-Null
        }
        $PathPM = "HKLM:\system\CurrentControlSet\services\snmp\Parameters\PermittedManagers"
        $PathTC = "HKLM:\system\CurrentControlSet\services\snmp\Parameters\TrapConfiguration"
        $PathTD = "HKLM:\system\CurrentControlSet\services\snmp\Parameters\TrapConfiguration\SchindlerRO"
        $PathVC = "HKLM:\system\CurrentControlSet\services\snmp\Parameters\ValidCommunities"
        $PathRFC = "HKLM:\system\CurrentControlSet\services\snmp\Parameters\RFC1156Agent"
        $PathEA = "HKLM:\system\CurrentControlSet\services\snmp\Parameters\ExtensionAgents"
        
        if ((Test-Path -path $PathTC) -eq $false){New-Item -path $PathTC }
        if ((Test-Path -path $PathTD) -eq $false){New-Item -path $PathTD }
        
        Set-ItemProperty -Path $PathRFC -name "sysServices" -Value ([Convert]::ToInt32('4f',16)) -Type "DWord"
        Set-ItemProperty -Path $PathRFC -name "sysLocation" -Value $sysLocation
        Set-ItemProperty -Path $PathRFC -name "sysContact" -Value $sysContact
        Set-ItemProperty -Path $PathVC -name "SchindlerRO" -Value ([Convert]::ToInt32('4',16)) -Type "DWord"
        Set-ItemProperty -Path $PathVC -name "SchindlerRW" -Value ([Convert]::ToInt32('8',16)) -Type "DWord"
        
        $PermittedManager = Get-Item -Path $PathPM
        $TrapDestination = Get-Item -Path $PathTD

        #Create a list of all custom Permitted Managers
        $count = $PermittedManager.ValueCount    
        for($i=1; $i -le $count; $i++){
            $Name = $PermittedManager.GetValue($i) 
            if ((($DefaultPM -contains $Name) -or ($DeletePM -contains $Name) -or ($Name -eq "")) -eq $False) {$PManager += $Name }
            Remove-ItemProperty -Path $PathPM -Name $i
        }

        #Create a list of all custom Trap Destinations
        $count = $TrapDestination.ValueCount    
        for($i=1; $i -le $count; $i++){
            $Name = $TrapDestination.GetValue($i)
            if ((($DefaultTD -contains $Name) -or ($DeleteTD -contains $Name) -or ($Name -eq "")) -eq $False) {$TDestination += $Name }  
            Remove-ItemProperty -Path $PathTD -Name $i
       }
         
    
        #Re-order Trap Destination
        #Set basic Trap Destination
        for($i=1; $i -le $DefaultTD.Count; $i++){
            Set-ItemProperty -Path $PathTD -name $i -Value $DefaultTD[$i-1]
        }
        #Set additional custom Trap Destination
        foreach ($Name in $TDestination ){
                Set-ItemProperty -Path $PathTD -name $i -Value $Name
                $i++
        }

        #Re-order Permitted Manager
        #Set basic Permitted Managers
        for($i=1; $i -le $DefaultPM.Count; $i++){
            Set-ItemProperty -Path $PathPM -name $i -Value $DefaultPM[$i-1]
        }
        #Set additional custom Permitted Managers
        foreach ($Name in $PManager ){
                Set-ItemProperty -Path $PathPM -name $i -Value $Name
                $i++
        }
        exit 0
    } catch {
        Write-Host "An error occured while writing to the registry on server $comp"
        exit 1
    }