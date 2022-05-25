#$WarningPreference = 'SilentlyContinue'
#Connect-AzAccount
#Loop all subscription

Get-AzSubscription | ForEach-Object {

$subscriptionName = $_.Name
    #Set subscription
Set-AzContext -SubscriptionId $_.SubscriptionId
        #Get all Sql Managed Instance
       Get-AzSqlInstance | select-object ManagedInstanceName,ResourceGroupName        | ForEach-Object {    
        $InstanceName = $_.ManagedInstanceName  
        $ResGrpName = $_.ResourceGroupName  
        #Get all Database in Sql Managed Instance

        Get-AzSqlInstanceDatabase -InstanceName $InstanceName -ResourceGroupName $ResGrpName | select-object Name | ForEach-Object {    

            $DbName = $_.Name

            #Get actual PITR and LTR for each Db
            $ActualPITR=Get-AzSqlInstanceDatabaseBackupShortTermRetentionPolicy -InstanceName $InstanceName -ResourceGroupName $ResGrpName -DatabaseName $DbName | select-object  RetentionDays
            $ActualLTR=Get-AzSqlInstanceDatabaseBackupLongTermRetentionPolicy  -InstanceName $InstanceName -ResourceGroupName $ResGrpName -DatabaseName $DbName | select-object  WeeklyRetention , MonthlyRetention    

            #if ($InstanceName -eq 'sqlmi-shh-dev-rmp-01' ){
                #Set values based on environment type

                if($InstanceName -like '*prod*') {

                      $Month="P12M"
                      $Week="P26W"
                      $Day=35
                } else {
                      $Month="P6M"
                      $Week="P12W"
                      $Day=28
                }    

                #Print values

                [PSCustomObject] @{

                    ManagedInst = $InstanceName
                    ResGrp =$ResGrpName
                    Db = $DbName
                    Mesi = $Month
                    Settimane = $Week
                    Giorni = $Day
                    ActualRetentionDays = $ActualPITR.RetentionDays
                    ActualLTRWeeklyRetention = $ActualLTR.WeeklyRetention
                    ActualLTRMonthlyRetention = $ActualLTR.MonthlyRetention

                }
                #Set LTR if different from policy
                if($ActualLTR.WeeklyRetention -ne $Week -or $ActualLTR.MonthlyRetention -ne $Month) {  
                    Set-AzSqlInstanceDatabaseBackupLongTermRetentionPolicy -ResourceGroupName $ResGrpName -InstanceName $InstanceName -DatabaseName $DbName  -WeeklyRetention $Week -MonthlyRetention $Month
                }

                #Set PITR if different from policy

                if($ActualPITR.RetentionDays -ne $Day) {
                    Set-AzSqlInstanceDatabaseBackupShortTermRetentionPolicy -ResourceGroupName $ResGrpName -InstanceName $InstanceName -DatabaseName $DbName -RetentionDays $Day
                }
              #} 
        }
    }

}