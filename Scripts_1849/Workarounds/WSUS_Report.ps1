
###################################### Connection to GDC WSUS Server #############################################

Remove-Item C:\Report_SHH.txt -Force -ErrorAction SilentlyContinue
Remove-Item C:\Report_KG.txt -Force -ErrorAction SilentlyContinue

Function SHH_Report

{
Import-Module -Name PoshWSUS
 try
          {

            $SHH_WSUS = "shhwsr1238"
            Write-host "Checking the Schinlder WSUS server for the Server $Server"
            Connect-PSWSUSServer -WsusServer $SHH_WSUS -port 8530
            $Servers_Failed = Get-PSWSUSClient -IncludedInstallationState Failed
            $Servers_Pending = Get-PSWSUSClient -IncludedInstallationState InstalledPendingReboot
            $Servers_Group = Get-PSWSUSGroup
            Write-Output "############ Servers with Patch Failed #############" >> C:\Report_SHH.txt
            $Servers_Failed >> C:\Report_SHH.txt
            Write-Output "" >> C:\Report_SHH.txt
            Write-Output "############ Servers Pending Reboot #############" >> C:\Report_SHH.txt
            $Servers_Pending >> C:\Report_SHH.txt
            Disconnect-PSWSUSServer  
          }
          catch
          {
            Write-Warning "Connection to SHHWSR1238 Schindler WSUS server was not possible or the object doesn't exist"
          }

}
###################################### Connection to KG WSUS Server #############################################


Function KG_Report

{

Import-Module -Name PoshWSUS
            try
          {

            $KG_WSUS = "shhwsr1242"
            Write-host "Checking the Schinlder WSUS server for the Server $Server"
            Connect-PSWSUSServer -WsusServer $KG_WSUS -port 8530
            $Servers_Failed = Get-PSWSUSClient -IncludedInstallationState Failed
            $Servers_Pending = Get-PSWSUSClient -IncludedInstallationState InstalledPendingReboot
            $Servers_Group = Get-PSWSUSGroup
            Write-Output "############ Servers with Patch Failed #############" >> C:\Report_KG.txt
            $Servers_Failed >> C:\Report_KG.txt
            Write-Output "" >> C:\Report_KG.txt
            Write-Output "############ Servers Pending Reboot #############">> C:\Report_KG.txt
            $Servers_Pending >> C:\Report_KG.txt
            Disconnect-PSWSUSServer  
          }
          catch
          {
            Write-Warning "Connection to SHHWSR1242 Schindler WSUS server was not possible or the object doesn't exist"
          }

}

SHH_Report
KG_Report

