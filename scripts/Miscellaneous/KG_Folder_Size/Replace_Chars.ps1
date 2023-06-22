
[array]$Report = Import-Csv .\KGFolderSize.csv -Delimiter ","

($report | Out-String) -replace '\?',',' > .\test.csv

Get-Content .\test.csv | Select-Object -skip 3 | Out-File .\test.txt

$file = Get-Content .\test.txt 

$file -replace '\s',''





$ReportSize = foreach($i in $Report){
    $i.Date
    $i.FileSize.replace('?',',')
    $i.FolderName
} 
$ReportSize | out-file Size.txt



$report | foreach {if($_.FileSize -like "*?*"){$_ -replace '/?',"."}}

$report | Export-Csv .\test.csv

$InputFile=Import-csv .\Users.csv
foreach($i in $InputFile){
 $UserInfo=Get-ADUser $i.Username.replace('$','')
 if($UserInfo){
   $i | Add-Member -NotePropertyName DisplayName -NotePropertyValue $($i.Displayname)
   $i | Add-Member -NotePropertyName GivenName -NotePropertyValue $($i.GivenName)
   $i | Add-Member -NotePropertyName Surname -NotePropertyValue $($i.Surname)
   $i | Add-Member -NotePropertyName Notes -NotePropertyValue ""
}else{
   $i | Add-Member -NotePropertyName DisplayName -NotePropertyValue ""
   $i | Add-Member -NotePropertyName GivenName -NotePropertyValue ""
   $i | Add-Member -NotePropertyName Surname -NotePropertyValue ""
   $i | Add-Member -NotePropertyName Notes -NotePropertyValue "No Information Found"  
 }
 
}




[array]$ReportC = $Report | Foreach-Object {$_ -replace "\?", "."}

$Report -replace "\?", "."


$arrayObjects = $ReportCorrect | ForEach-Object {
     [PSCustomObject]@{'Date' = $_}
}
$arrayObjects | Export-Csv -Path "test.csv" -NoTypeInformation | 

$test = Import-Csv .\test.csv -Delimiter ";"




#Read more: https://www.sharepointdiary.com/2021/03/powershell-export-array-to-csv.html#ixzz83lXuRpCl



$ReportCorrect | Foreach-Object {
    Select-Object Date,FileSize,FolderName| Export-CSV -Path test.csv -Append
}


$ReportCorrect | Export-Csv -NoTypeInformation .\KGFolderSizeCorrect.csv
