$var = gc "D:\Repository\Working\Antonio\Replace_Chars\KGsFolderSizeReport.csv"
convert-csv
$var.replace("Â"+"\s",'.')
$var.replace("\d.\s",'.')


#[System.IO.File]::WriteAllText(
#        'D:\Repository\Working\Antonio\Replace_Chars\KGsFolderSizeReport.csv',
#        ([System.IO.File]::ReadAllText('D:\Repository\Working\Antonio\Replace_Chars\KGsFolderSizeReport.csv') -replace '\s')
#    )


(Get-Content -Encoding UTF8 C:\Temp\ads.txt) | % {$_ -replace '"', ""} | out-file -Encoding UTF8 -FilePath C:\temp\ads_UTF8.csv -Force
gc "D:\Repository\Working\Antonio\Replace_Chars\KGsFolderSizeReport.csv" | out-file -Encoding UTF8 -FilePath "D:\Repository\Working\Antonio\Replace_Chars\KGsFolderSizeReport_Convert.csv" -Force