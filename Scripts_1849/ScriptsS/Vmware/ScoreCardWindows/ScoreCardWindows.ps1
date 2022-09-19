Import-Module ActiveDirectory
Add-PSSnapin -Name VMware*
Connect-VIServer shhwsr0208
Connect-VIServer shhwsr0213

$logfile_path="D:\Scripts\Schindler\Vmware\ScoreCardWindows\ScoreCardWindows.log"
$Date = Get-Date
$VMList = @()
$Datacenter = Get-Datacenter -Name SHH,SHH_DR
$VMS = $Datacenter | Get-VM
"++++++ ScoreCared Report Windows $Date ++++++" | Out-File -FilePath $logfile_path -Append
Foreach ($VM in $VMS) {
  $Obj = "" | Select Name,PowerState,OS
  $Obj.Name = $VM.Name
  $Obj.PowerState = $VM.PowerState
  $Obj.OS = $VM.Guest.OSFullName
  $VMList += $Obj
}
"====== ALL VM's poweredOn and poweredOff" | Out-File -FilePath $logfile_path -Append
$Total = $VMList.count
"Total amount of VM's:             $Total" | Out-File -FilePath $logfile_path -Append
$WinSrv = $VMlist | Where-Object {$_.OS -like "*Windows Server*"}
$TotalWinSrv = $WinSrv.count
"Total amount of Windows Server:   $TotalWinSrv" | Out-File -FilePath $logfile_path -Append
$Win2003 = $WinSrv | Where-Object {$_.OS -like "*Windows Server 2003*"}
$Win2008 = $WinSrv | Where-Object {$_.OS -like "*Windows Server 2008*"}
$Win2012 = $WinSrv | Where-Object {$_.OS -like "*Windows Server 2012*"}
$TotalWin2003 = $Win2003.count
$TotalWin2008 = $Win2008.count
$TotalWin2012 = $Win2012.count
$TotalWin = $TotalWin2003 + $TotalWin2008 + $TotalWin2012
"Total Windows Server 2003:   $TotalWin2003" | Out-File -FilePath $logfile_path -Append
"Total Windows Server 2008:   $TotalWin2008" | Out-File -FilePath $logfile_path -Append
"Total Windows Server 2012:   $TotalWin2012" | Out-File -FilePath $logfile_path -Append
if ($TotalWin -ne $TotalWinSrv){
    $Dif = $TotalWinSrv - $TotalWin
    "Total Other Win Server Version:   $Dif" | Out-File -FilePath $logfile_path -Append
}
" "
"====== Only VM's poweredOn" | Out-File -FilePath $logfile_path -Append
$WinSrvPO = $WinSrv | Where-Object {$_.PowerState -eq "PoweredOn"}
$TotalWinSrv = $WinSrvPO.count
"Total amount of Windows Server:   $TotalWinSrv" | Out-File -FilePath $logfile_path -Append
$Win2003 = $WinSrvPO | Where-Object {$_.OS -like "*Windows Server 2003*"}
$Win2008 = $WinSrvPO | Where-Object {$_.OS -like "*Windows Server 2008*"}
$Win2012 = $WinSrvPO | Where-Object {$_.OS -like "*Windows Server 2012*"}
$TotalWin2003 = $Win2003.count
$TotalWin2008 = $Win2008.count
$TotalWin2012 = $Win2012.count
$TotalWin = $TotalWin2003 + $TotalWin2008 + $TotalWin2012
"Total Windows Server 2003:   $TotalWin2003" | Out-File -FilePath $logfile_path -Append
"Total Windows Server 2008:   $TotalWin2008" | Out-File -FilePath $logfile_path -Append
"Total Windows Server 2012:   $TotalWin2012" | Out-File -FilePath $logfile_path -Append
if ($TotalWin -ne $TotalWinSrv){
    $Dif = $TotalWinSrv - $TotalWin
    "Total Other Win Server Version:   $Dif" | Out-File -FilePath $logfile_path -Append
}
" "  | Out-File -FilePath $logfile_path -Append
#Disconnect-VIServer shhwsr0208
#Disconnect-VIServer shhwsr0213
