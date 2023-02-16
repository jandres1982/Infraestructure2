$ServerList = Get-Content -Path "D:\Scripts\Swisscom\VxBlock-Windows-VM-Lists\output\02_WIN_GlobalDOM_NOIDM_NOCITRIX\20170716-050000-WIN_GlobalDOM_NOIDM_NOCITRIX-Count840.txt"
$ServerListNoStaticRoutes = "C:\Temp\tstservers.txt"
"" | out-file $ServerListNoStaticRoutes
foreach ($Server in $ServerList) {
  try{
    $StaticRoutes = Invoke-Command -ComputerName $server -ScriptBlock {$route = route print ; $route -like "*     6*"}
    $NoStaticRoutes = $StaticRoutes.count
    "$NoStaticRoutes  $Server"
    if ($NoStaticRoutes -eq 0) {$server | out-file $ServerListNoStaticRoutes -Append}
  }
  catch {"no connection to server $server"}
}