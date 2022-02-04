#Fixed variables
$WorkloadType = 'AzureVM'
$BackupPolicyNameShort = 'vm-short-01am-01'
$BackupPolicyNameMedium = 'vm-medium-01am-01'
$BackupPolicyNameLong = 'vm-long-01am-01'
$DailyRetention = '30'
$WeeklyRetention = '12'
$MonthlyRetention = '12'

Set-AzContext -Subscription $(SubscriptionName)

#daily

Write-Verbose "Getting a Base Backup Schedule Policy object..."
$SchPol = Get-AzRecoveryServicesBackupSchedulePolicyObject -WorkloadType $WorkloadType
$SchPol.ScheduleRunTimes.Clear()
$Dt  = Get-Date
$hour = '1'
$Dt1 = Get-Date -Year $Dt.Year -Month $Dt.Month -Day $Dt.Day -Hour $hour -Minute 0 -Second 0 -Millisecond 0
$SchPol.ScheduleRunTimes.Add($Dt1.ToUniversalTime())
Write-Verbose "Getting a Base Backup Retention Policy object..."
$RetPol = Get-AzRecoveryServicesBackupRetentionPolicyObject -WorkloadType $WorkloadType




$RetPol.DailySchedule.DurationCountInDays = $DailyRetention
$RetPol.IsWeeklyScheduleEnabled = $false
$RetPol.IsMonthlyScheduleEnabled = $false
$RetPol.IsYearlyScheduleEnabled= $false





Write-Verbose "Getting the existing Azure Recovery Services Vault..."
$vault = Get-AzRecoveryServicesVault -Name $(RSVaultName)
Write-Verbose "Setting Azure Recovery Services Vault Context..."
Set-AzRecoveryServicesVaultContext -Vault $vault -ErrorAction Stop -WarningAction SilentlyContinue

Write-Verbose "Creating Azure Backup Protection Policy..."
$ProtectionPolicy = New-AzRecoveryServicesBackupProtectionPolicy -Name $BackupPolicyNameShort -WorkloadType $WorkloadType -RetentionPolicy $RetPol -SchedulePolicy $SchPol


$Pol = Get-AzRecoveryServicesBackupProtectionPolicy -Name $BackupPolicyNameShort
$pol.SnapshotRetentionInDays=5
Set-AzRecoveryServicesBackupProtectionPolicy -Policy $Pol

#medium

Write-Verbose "Getting a Base Backup Schedule Policy object..."
$SchPol = Get-AzRecoveryServicesBackupSchedulePolicyObject -WorkloadType $WorkloadType
$SchPol.ScheduleRunTimes.Clear()
$Dt  = Get-Date
$hour = '1'
$Dt1 = Get-Date -Year $Dt.Year -Month $Dt.Month -Day $Dt.Day -Hour $hour -Minute 0 -Second 0 -Millisecond 0
$SchPol.ScheduleRunTimes.Add($Dt1.ToUniversalTime())
Write-Verbose "Getting a Base Backup Retention Policy object..."
$RetPol = Get-AzRecoveryServicesBackupRetentionPolicyObject -WorkloadType $WorkloadType



$RetPol.DailySchedule.DurationCountInDays = $DailyRetention
$RetPol.WeeklySchedule.DurationCountInWeeks = $WeeklyRetention
$RetPol.IsWeeklyScheduleEnabled = $true
$RetPol.IsMonthlyScheduleEnabled = $false
$RetPol.IsYearlyScheduleEnabled= $false





Write-Verbose "Getting the existing Azure Recovery Services Vault..."
$vault = Get-AzRecoveryServicesVault -Name $(RSVaultName)
Write-Verbose "Setting Azure Recovery Services Vault Context..."
Set-AzRecoveryServicesVaultContext -Vault $vault -ErrorAction Stop -WarningAction SilentlyContinue

Write-Verbose "Creating Azure Backup Protection Policy..."
$ProtectionPolicy = New-AzRecoveryServicesBackupProtectionPolicy -Name $BackupPolicyNameMedium -WorkloadType $WorkloadType -RetentionPolicy $RetPol -SchedulePolicy $SchPol


$Pol = Get-AzRecoveryServicesBackupProtectionPolicy -Name $BackupPolicyNameMedium
$pol.SnapshotRetentionInDays=5
Set-AzRecoveryServicesBackupProtectionPolicy -Policy $Pol


#long

Write-Verbose "Getting a Base Backup Schedule Policy object..."
$SchPol = Get-AzRecoveryServicesBackupSchedulePolicyObject -WorkloadType $WorkloadType
$SchPol.ScheduleRunTimes.Clear()
$Dt  = Get-Date
$hour = '1'
$Dt1 = Get-Date -Year $Dt.Year -Month $Dt.Month -Day $Dt.Day -Hour $hour -Minute 0 -Second 0 -Millisecond 0
#Write-Verbose "Setting Backup Policy Schedule in UTC Timezone: $($dt1.ToUniversalTime())"
$SchPol.ScheduleRunTimes.Add($Dt1.ToUniversalTime())
#$SchPol.ScheduleRunTimes.Add($Dt1.ToLocalTime())
Write-Verbose "Getting a Base Backup Retention Policy object..."
$RetPol = Get-AzRecoveryServicesBackupRetentionPolicyObject -WorkloadType $WorkloadType




$RetPol.DailySchedule.DurationCountInDays = $DailyRetention
$RetPol.WeeklySchedule.DurationCountInWeeks = $WeeklyRetention
$RetPol.MonthlySchedule.DurationCountInMonths = $MonthlyRetention
$RetPol.MonthlySchedule.RetentionScheduleFormatType = 'Daily'
$RetPol.IsWeeklyScheduleEnabled = $true
$RetPol.IsMonthlyScheduleEnabled = $true
$RetPol.IsYearlyScheduleEnabled= $false





Write-Verbose "Getting the existing Azure Recovery Services Vault..."
$vault = Get-AzRecoveryServicesVault -Name $(RSVaultName)
Write-Verbose "Setting Azure Recovery Services Vault Context..."
Set-AzRecoveryServicesVaultContext -Vault $vault -ErrorAction Stop -WarningAction SilentlyContinue

Write-Verbose "Creating Azure Backup Protection Policy..."
$ProtectionPolicy = New-AzRecoveryServicesBackupProtectionPolicy -Name $BackupPolicyNameLong -WorkloadType $WorkloadType -RetentionPolicy $RetPol -SchedulePolicy $SchPol


$Pol = Get-AzRecoveryServicesBackupProtectionPolicy -Name $BackupPolicyNameLong
$pol.SnapshotRetentionInDays=5
Set-AzRecoveryServicesBackupProtectionPolicy -Policy $Pol
