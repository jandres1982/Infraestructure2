param([string]$vm,
[string]$date,
[string]$email,
[string]$Request,
[string]$Type,
[string]$AzServAcc,
[string]$AzServPw)

$date = $date -as [datetime]

Write-Output "vm: $vm"
Write-Output "date: $date"
Write-Output "email: $email"
Write-Output "Type: $Type"

Function Check_Server_Azure ([string]$vm)
{
$subs=Get-AzSubscription | Where-Object {$_.Name -match "s-sis-[aec][upmh]*"}
Write-Output "Check if the $vm is in Azure"
foreach ($sub in $subs)
    {
    Select-AzSubscription -Subscription "$sub"
        $VmProfile = get-azvm -Name $vm
            if ($VmProfile -eq $null)
                {
                    Write-Output "$vm is not in $sub"
                }else
                    {
                    [hashtable]$Data = @{}
                    $Data = @{VmProfile=$vmprofile;sub=$sub}
                    Return $Data
                    Break
                    }
    }
}

Function Azure_Snap_Task
{
$dt = $date
$Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-File D:\Snapshots\Scripts\Snapshots_v1.ps1 -vm $vm -sub $sub -email $email -type $type"
$taskname = "Snapshots_DevOps_$vm"
$Trigger = New-ScheduledTaskTrigger -Once -At $dt
$Settings = New-ScheduledTaskSettingsSet
Register-ScheduledTask -TaskName $taskname `
   -TaskPath "\Snapshots" `
   -Action $Action `
   -User $AzServAcc `
   -Password $AzServPw `
   -Trigger $trigger `
   -Settings $Settings `
   -RunLevel Highest -Force
}


#Main
Select-AzSubscription -Subscription "$sub"
$Data = Check_Server_Azure -vm $vm
$rg = $Data.VmProfile.ResourceGroupName
$sub = $Data.Sub.Name

If ($rg -ne $null)
    {
        Azure_Snap_Task
    }else
        {
        Write-Output "Server $vm was not found in Azure"
        }