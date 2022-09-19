
clear-host
$computers = gc "D:\Repository\Working\Antonio\CPU_Count\Computers.txt" #Variable to define Servers to be added.
$destination = "C$\temp\"
foreach ($computer in $computers) {#For each Server Selected in the Computers.txt file
if ((Test-Path -Path \\$computer\$destination)) { #Verify if is reachable 

#$CPU = Get-WmiObject -computername $computer -class win32_processor | select-object numberofcores | measure

$Log_CPU = Get-WmiObject -class win32_processor –computername $computer -Property  "NumberOfLogicalProcessors"| Select-Object -Property "NumberOfLogicalProcessors" | measure
$CPU_Count = $Log_CPU.count

$RAM = Get-WmiObject Win32_PhysicalMemory -computername $computer | Measure-Object -Property Capacity -Sum
$RAM_GB = [math]::truncate($RAM.sum / 1GB)


echo "$computer;$CPU_Count;$RAM_GB" >> "D:\Repository\Working\Antonio\CPU_Count\CPU_Count.txt"
echo "$computer;$CPU_Count;$RAM_GB"

}


else {
Write-host "Host not recheable"
}
}