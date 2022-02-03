$free_mb = $(Get-WmiObject Win32_Volume | Where-Object {$_.DriveLetter -eq "c:" }).FreeSpace 
$free_gb = [math]::round($free_mb/1Gb,0)
if ($free_gb -lt "20")
{write-host "Warning C:\ drive near to get full, extend or check asap"
exit 1
}else
{write-host "All Ok"
exit 0
}