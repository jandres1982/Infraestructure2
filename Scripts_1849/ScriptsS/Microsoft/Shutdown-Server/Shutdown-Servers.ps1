$servers = get-content .\Servers.txt

Write-host "This will shutdown servers in the Servers.txt file"
$list = read-host "Press L if you want so see the list of servers"
$response = read-host "Press Y to continue, any other key to abort."

if ($list -eq "l") {Write-Output $servers}

if ($response -like "y") {
foreach ($server in $servers) {
Write-host "$server :"
Write-output "shutdown /m \\$server /s /t 10"
}
}