[string]$vm
[datetime]$date
[string]$email
[string]$sub
[System.String]$AzServPw = "$(AzServPw)"

#[string]$vm = "$(vm)"
#[datetime]$date = "$(date)"
#[string]$email = "$(email)"
#[string]$sub = "$(sub)"

Write-Output "vm: $vm"
Write-Output "date: $date"
Write-Output "email: $email"
Write-Output "sub: $sub"

import-module -Name Az.compute
import-module -Name Az.Storage
import-module -Name Az.Accounts

$subs=Get-AzSubscription | Where-Object {$_.Name -match "s-sis-[aec][upmh]*"}
Write-host "$vm"
foreach ($sub in $subs)
    {
    Select-AzSubscription -Subscription "$sub"
        $Az_check = get-azvm -Name $vm
            if ($Az_check -eq $null)
                {
                #write-host "$vm is not in Azure $sub"
                }else
                    {
                    $dt = $date
                    $Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-File D:\Snapshots\Scripts\Snapshots_v1.ps1 -vm $vm -sub $sub"
                    $taskname = "Snapshots_DevOps_$vm"
                    $Trigger = New-ScheduledTaskTrigger -Once -At $dt
                    $Settings = New-ScheduledTaskSettingsSet
                    Register-ScheduledTask -TaskName $taskname `
                       -TaskPath "\Snapshots" `
                       -Action $Action `
                       -User $(AzServAcc) `
                       -Password $AzServPw `
                       -Trigger $trigger `
                       -Settings $Settings `
                       -RunLevel Highest -Force

                    }
        }