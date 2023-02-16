Start-Process notepad++ "D:\Repository\Working\Antonio\Visual_C++\server_list.txt" -Wait
$Servers = gc "D:\Repository\Working\Antonio\Visual_C++\server_list.txt"

$computername = "invwsr0005"

foreach ($computername in $Servers)
{
Write-Host "*****$computername****"
$VisualC_2008_64 = "{4B6C7001-C7D6-3710-913E-5BC23FCE91E6}"
$VisualC_2008_32 = "{1F1C2DFC-2D24-3E06-BCB8-725134ADF989}"
$VisualC_check = Get-WmiObject Win32_Product -ComputerName $computername | Select-Object -Property IdentifyingNumber, Name
$Get_VisualC_2008_64 = Get-WmiObject Win32_Product -ComputerName $computername | Where-Object {$_.IdentifyingNumber -eq $VisualC_2008_64}
$Get_VisualC_2008_32 = Get-WmiObject Win32_Product -ComputerName $computername | Where-Object {$_.IdentifyingNumber -eq $VisualC_2008_32}

if ($Get_VisualC_2008_64) {

  $Get_VisualC_2008_64.Uninstall()
}
else {
  $VisualC_2008_64 + ' is not installed on ' + $ComputerName
}


if ($Get_VisualC_2008_32) {
  $Get_VisualC_2008_32.Uninstall()
}
else {
  $VisualC_2008_32 + ' is not installed on ' + $ComputerName
}

}