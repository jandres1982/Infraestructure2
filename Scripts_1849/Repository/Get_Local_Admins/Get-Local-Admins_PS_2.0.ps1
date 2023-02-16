$server = "aszwsr0011"
$group = [ADSI]"WinNT://$server/administrators"
$group.Invoke('Members') | % {$_.GetType().InvokeMember('Name', 'GetProperty', $null, $_, $null)}
