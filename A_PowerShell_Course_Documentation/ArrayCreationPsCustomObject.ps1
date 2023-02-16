$csvtest = Import-Csv -Path .\employees.csv

$newArray = @()
foreach ($object in $csvtest) {

    if("Machine Learning Engineer",
    "DevOps Engineer",
    "HR Manager",
    "DevOps Engineer" -eq $object.'job title'){
        $newObject = @{
        "Nombre" = "$($object.'First Name')"
        "Apellido" = "$($object.'Last Name')"
        "Email" = "$($object.'Email')"
        }
        $newArray += $newObject
    }
    <# $currentItemName is the current item #>
}

$info = Get-Content .\structure.json | Out-String | ConvertFrom-Json
$($info | Where-Object {$_.topping.id -eq "5002"}).id

$var = $info[2].batters.batter
$ps = [PSCustomObject]@{"id" = "1500";"type" = "Chocolatina"}