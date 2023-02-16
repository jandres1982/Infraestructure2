$servers = Get-Content .\servers.txt

foreach ($server in $servers) {
Invoke-Command -ComputerName $server -ScriptBlock {
$ip = (Get-WmiObject Win32_NetworkAdapterConfiguration | where { (($_.IPEnabled -ne $null) -and ($_.DefaultIPGateway -ne $null)) } | select IPAddress -First 1).IPAddress[0]
write-host "$env:COMPUTERNAME($ip) - TPING"
cmd /c "C:\admin\tools\tping.exe 171.25.85.74 4119"}
}