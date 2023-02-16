$servers = get-content .\Servers.txt

foreach ($server in $servers) {
Write-host "$server :"
schtasks /S $server /run /TN SHH_SRV-STATICROUTE01
}