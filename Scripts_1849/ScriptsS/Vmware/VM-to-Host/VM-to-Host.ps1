$hostlist = "D:\Scripts\Schindler\Vmware\VM-to-Host\hostlist.csv"
$hosts = Import-CSV $hostlist

Foreach ($host in $hosts) {
    connect-viserver $host
}