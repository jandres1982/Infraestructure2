param([string]$vm,
[string]$date,
[string]$email,
[string]$Request,
[string]$Type,
[string]$Sub,
[string]$AzServAcc,
[string]$AzServPw)

#$User = "intshhazuredevops@global.schindler.com"
#$PWord = ConvertTo-SecureString -String $AzServPw -AsPlainText -Force
#$Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User,$PWord
#Connect-AzAccount -Credential $Credential

$response = Invoke-WebRequest -Uri 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&client_id=2f9eefbb-eb19-486e-9bda-60c11cae3c08&resource=https://management.azure.com/' -Method GET -Headers @{Metadata="true"}
$content = $response.Content | ConvertFrom-Json
$ArmToken = $content.access_token
Connect-AzAccount -AccessToken $ArmToken -Subscription $sub -AccountId $content.client_id

$date = $date -as [datetime]
Connect-AzAccount
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