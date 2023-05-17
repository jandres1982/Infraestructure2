param([string]$vm,
[string]$date,
[string]$email,
[string]$Request,
[string]$Type,
[string]$Sub,
[string]$AzServAcc,
[string]$AzServPw,
[string]$Requester)



$User = "intshhazuredevops@global.schindler.com"
$PWord = ConvertTo-SecureString -String $AzServPw -AsPlainText -Force
Write-Host "$user and $Pword"
$Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User,$PWord
Connect-AzAccount -Credential $Credential

#$identity = Get-AzUserAssignedIdentity -ResourceGroupName '' -Name 'shhwsr1849'
#Get-AzVM -ResourceGroupName contoso -Name testvm | Update-AzVM -IdentityType UserAssigned -IdentityId $identity.Id
#Connect-AzAccount -Identity -AccountId $identity.ClientId # Run on the virtual machine

$date = $date -as [datetime]
Write-Output "vm: $vm"
Write-Output "date: $date"
Write-Output "email: $email"
Write-Output "Type: $Type"

#Check date (TO DO)


Function Send_Email
{
$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"
$to = "$Requester"
$Subject = "Snapshot Should be Scheduled for $vm"
$Body = @"
Please check DevOps Server Agent to verify the task is created.
Machine: $vm
Subscription_ID: $sub
e-mail:$email
"@
Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body
}


Function Check_Server_Azure ([string]$vm)
{
$subs=Get-AzSubscription | Where-Object {$_.Name -match "s-sis-[aec][upmh]*"}
Write-Output "Check if the $vm is in Azure"
foreach ($sub in $subs)
    {
    Set-AzContext -Subscription "$sub"
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
$Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-File D:\Snapshots\Scripts\Snapshots_v2.ps1 -vm $vm -sub $sub -email $email -type $type -requester $requester"
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
        Send_Email
    }else
        {
        Write-Output "Server $vm was not found in Azure"
        Write-Error "$vm was not found in Azure"
        }