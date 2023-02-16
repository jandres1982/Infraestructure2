#
#$WsusServer = "shhwsr1238"
#$WsusPort = "8530"
#
#
#if( $null -eq (Get-Module PoshWSUS) ){
#            Import-Module PoshWSUS
#        }
# Connect-PSWSUSServer -WsusServer $WsusServer -Port $WsusPort > $null
#
$servers = Get-PSWSUSClient | Sort-Object FullDomainName | Select-Object FullDomainName | out-string > "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Get-Windows-Update-Group\Check Patches\Servers_1238.txt"
$Servers = gc "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Get-Windows-Update-Group\Check Patches\Servers_1238.txt"
$first = $Servers[0]
$second = $Servers[1]
$third = $Servers[2]
$Servers | where { $_ -ne $first -and $_ -ne $second -and $_ -ne $third } | out-file "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Get-Windows-Update-Group\Check Patches\Servers_1238_new.txt"

$servers = gc "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Get-Windows-Update-Group\Check Patches\Servers_1238_new.txt"


function Get-PatchingStatus {
    [CmdletBinding()]
    param (
        # One or more computer in a Wsus
        [Parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline
            )]
        [System.Array]
        $ComputerName,

        # The WSUS server 
        [Parameter(
            Mandatory,
            Position = 1
         )]
        [String]
        $WsusServer,

        # Parameter help description
        [Parameter(
            Position = 2
        )]
        [ValidateSet(80,8530,443)]
        [int]
        $WsusPort = 8530
    )
    
    begin {
        if( $null -eq (Get-Module PoshWSUS) ){
            Import-Module PoshWSUS
        }
        Connect-PSWSUSServer -WsusServer $WsusServer -Port $WsusPort > $null
    }
    
    process {
        $PatchingStatus = foreach($Computer in $ComputerName){
            $ServerWSUSInfos = Get-PSWSUSClient -Computername $Computer | 
                                Select-Object FullDomainName,IPAddress,OSDescription,ComputerGroup
                                #,LastSyncTime,LastReportedStatusTime
        
        
            $ServerMissingUpdates = Get-PSWSUSUpdatePerClient -ComputerName $Computer | 
                                        Where-Object { 
                                        ($_.UpdateInstallationState -ne 'NotApplicable') -and
                                        ($_.UpdateInstallationState -ne 'Installed') -and
                                        ($_.UpdateApprovalAction -eq 'Install')
                                    }
            
            [PSCustomObject]@{
                Name = $Computer
                FQDN = $ServerWSUSInfos.FullDomainName
                IPAddress = $ServerWSUSInfos.IPAddress
                OSDescription =$ServerWSUSInfos.OSDescription
                ComputerGroup = "$($ServerWSUSInfos.ComputerGroup | Where-Object {$_ -ne 'All Computers'})"
                MissingUpdates = $ServerMissingUpdates.Count
                #LastReportedStatusTime = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId((get-date $ServerWSUSInfos.LastReportedStatusTime) ,[System.TimeZoneInfo]::Local.Id)
                #LastSyncTime = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId((get-date $ServerWSUSInfos.LastSyncTime) ,[System.TimeZoneInfo]::Local.Id)
            }        
        }
        # Returned value
        $PatchingStatus | Format-Table
    }
    
    end {}
}


Get-PatchingStatus -ComputerName $servers -WsusServer $WsusServer -WsusPort $WsusPort

