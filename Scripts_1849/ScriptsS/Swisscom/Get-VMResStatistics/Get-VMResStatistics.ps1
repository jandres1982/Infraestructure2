


function Get-VMUsageStatisticsPerVM {
[cmdletBinding()]
param(
     [Parameter(Mandatory=$True,
                Position=1,
                ValueFromPipeline=$true,
                ParameterSetName='VM or VMs',
                HelpMessage="VM/VMs to retive Statistics Information")]
                $vms
)


$metrics = "cpu.usage.average","mem.usage.average"
$start = (Get-Date).AddDays(-30)
$foldername = get-date -Format "ddMMyyyy"
$pathname = "D:\Scripts\Swisscom\Get-VMResStatistics"
New-Item -ItemType directory -Path "$pathname\$foldername"

$hashtable = get-stat -Entity $vms -Stat $metrics -Start $start | Select -ExcludeProperty Timestamp Entity, MetricID, Unit, Value,@{N="TimeStamp";E={$_.Timestamp.ToString("MMM dd yyyy HH:mm:ss")}} | group Entity, MetricID -AsHashTable -AsString

$vms | ForEach-Object {
    $vm = $_.Name
    $i = 0
    $metrics | ForEach-Object {
        $path = "$pathname\$foldername\" + $vm + '_' + $metrics[$i] + '.csv'
        $metric = $vm + ', ' + $metrics[$i]
        $hashtable.$metric | sort-object TimeStamp | export-csv $path -NoTypeInformation -UseCulture
        $i++   
    }
}
}#end function


function Get-VMUsageStatisticsOld {
[cmdletBinding()]
param(
     [Parameter(Mandatory=$True,
                Position=1,
                ValueFromPipeline=$true,
                ParameterSetName='VMs',
                HelpMessage="VM/VMs to retive Statistics Information")]
                $vms
)


$metrics = "cpu.usage.average","mem.usage.average"
$start = (Get-Date).AddDays(-30)
$foldername = get-date -Format "ddMMyyyy"
$pathname = "D:\Scripts\Swisscom\Get-VMResStatistics"
New-Item -ItemType directory -Path "$pathname\$foldername"

$hashtable = get-stat -Entity $vms -Stat $metrics -Start $start | Select -ExcludeProperty Timestamp Entity, MetricID, Unit, Value,@{N="TimeStamp";E={$_.Timestamp.ToString("MMM dd yyyy HH:mm:ss")}} | group Entity, MetricID -AsHashTable -AsString


ForEach ($met in $metrics) {
    $path = "$pathname\$foldername\" + $met + '.csv'
    ForEach ($vm in $vms) {
        $metric = "$vm" + ', ' + "$met"
        $hashtable.$metric | sort-object TimeStamp | export-csv $path -NoTypeInformation -UseCulture -Append
    }

}

}#end function


function Get-VMUsageStatistics {
[cmdletBinding()]
param(
     [Parameter(Mandatory=$True,
                Position=1,
                ValueFromPipeline=$true,
                ParameterSetName='VMs',
                HelpMessage="VM/VMs to retive Statistics Information")]
                $vms
)


#$metrics = "cpu.usage.average","mem.usage.average"
$metrics = "cpu.usagemhz.average"
#[DateTime]$end = "11.4.2016" 
$end = Get-Date
$start = $end.AddDays(-30)
$date = get-date -Format "ddMMyyyy"
$pathname = "D:\Scripts\Swisscom\Get-VMResStatistics"
$filename = "VMResStatistics_$date.csv"
$path = "$pathname\$filename"  
$stats = @()

ForEach ($vm in $vms) {
        Write-Host "Collecting data for" $vm "..."
        $stats +=  get-stat -Entity $vm -Stat $metrics -Start $start -Finish $end | Select -ExcludeProperty Timestamp Entity, MetricID, Unit, Value,@{N="TimeStamp";E={$_.Timestamp.ToString("MMM dd yyyy HH:mm:ss")}}
}
$stats | Export-Csv $path -NoTypeInformation -UseCulture

}#end function

$VMS = Get-VM
Get-VMUsageStatistics -vms $VMS
