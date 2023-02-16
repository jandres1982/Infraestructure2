$servers = Get-Content D:\Scripts\Swisscom\PSRemoteScripts\13_RegisterDNS\servers.txt

foreach ($server in $servers) {
write-host "$server - executing:"
invoke-command -ComputerName $server -ScriptBlock {ipconfig /registerdns}
}

