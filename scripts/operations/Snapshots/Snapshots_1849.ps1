param([string]$vm,
[string]$date,
[string]$email,
[string]$sub,
[string]$AzServAcc,
[string]$AzServPw)
#[System.String]$AzServPw = "$(AzServPw)"

$date = $date -as [datetime]
#$AzServAcc = $AzServAcc -as [System.String]
#$AzServPw = $AzServPw -as [System.String]


#Check access for the account:
#$AzServAcc = Get-AzKeyVaultSecret -VaultName 'kv-prod-devopsagents-01' -Name 'AzServAcc' -AsPlainText
#$AzServPw = Get-AzKeyVaultSecret -VaultName 'kv-prod-devopsagents-01' -Name 'AzServPw' -AsPlainText
#$AzServAcc = "intshhazuredevops"
#$AzServPw = "uX7V,p-#-890Ia"

#[string]$vm = "$(vm)"
#[datetime]$date = "$(date)"
#[string]$email = "$(email)"
#[string]$sub = "$(sub)"

Write-Output "vm: $vm"
Write-Output "date: $date"
Write-Output "email: $email"
Write-Output "sub: $sub"
#Write-Output "ServAcc: $AzServAcc"
$nubesuser = Get-AzKeyVaultSecret -VaultName 'kv-prod-devopsagents-01' -Name 'nubesuser' -AsPlainText
$nubespass = Get-AzKeyVaultSecret -VaultName 'kv-prod-devopsagents-01' -Name 'nubespass' -AsPlainText

#Write-Output "ServPw: $AzServPw"


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
                    #From David Sancho (sanchod1)
                    Import-Module vmware.vimautomation.core
                    $vcenterscs = 'vcenterscs.global.schindler.com'                  
                    $desktop = $vm
                    Connect-VIServer -Server $vcenterscs  -User $nubesuser -Password $nubespass
                    $Exists = get-vm -name $desktop -ErrorAction SilentlyContinue
                    If ($Exists){
                            #Shutdown-VMGuest -VM $desktop -Confirm:$False
                            #Start-Sleep -seconds 60
                            New-Snapshot -VM $desktop -Name $request -Memory 
                            Start-Sleep -seconds 60
                            #Start-VM -VM $desktop -RunAsync
                                }
                                Else {
                                        Connect-VIServer -Server $vcenternubes4  -User $nubesuser -Password $nubespass
                                        #Shutdown-VMGuest -VM $desktop -Confirm:$False
                                        #Start-Sleep -seconds 60
                                        New-Snapshot -VM $desktop -Name $(request) -Memory 
                                        Start-Sleep -seconds 60
                                        #Start-VM -VM $desktop -RunAsync
                                    }
                }else
                    {
                    $dt = $date
                    $Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-File D:\Snapshots\Scripts\Snapshots_v1.ps1 -vm $vm -sub $sub -email $email"
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
        }
        #                       