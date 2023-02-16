clear-host

$destination = "c$\temp" #(Where to copy in the server)

echo ""

echo "Hello and Welcome to the single installation package Script"

echo ""

echo "Please remember to download the package from the oficial MS Web page:"
echo "https://www.catalog.update.microsoft.com/Home.aspx"
echo "and place it in the current folder of this script"

echo ""

echo "Current MS Packages in the the script folder"
echo ""
ls | findstr windows

echo ""

$Package_name = Read-Host = 'Please provide the Package name (The one that ends in .msu)'
$Cab_name = Read-Host = 'Please provide a the CAB file to install (just the file name, for example:WindowsXX-KBXXXXXXX-x64.cab'
$add_server = Read-Host = 'Please add the server to be patched'

Remove-Item "D:\Repository\Working\Antonio\Installing MSU files\Computers.txt" -Recurse -Force #cleaning
echo $add_server >> "D:\Repository\Working\Antonio\Installing MSU files\Computers.txt"
$computers = gc "D:\Repository\Working\Antonio\Installing MSU files\Computers.txt"

#$Package_name = "windows6.1-kb4103718-x64_c051268978faef39e21863a95ea2452ecbc0936d.msu" #Change with the name of the package (requiered)
#$Cab_name = "Windows6.1-KB4103718-x64.cab"

$local_file = "D:\Repository\Working\Antonio\Installing MSU files\$Package_name" #Place the package in the local folder of this script (required)
$Source_Path = "\\$computer\$destination\$Package_name" #change with the name of the MSU package (required)
$Destination_Path = "\\$computer\$destination\SWInstall"



   foreach ($computer in $computers) {  #<For> each Server Selected in the Computers.txt file
             Copy-Item $local_file -Destination \\$computer\$destination -Recurse #Copying the file that will run
             echo "File Copied"
             New-Item -Path "$Destination_Path" -type directory -Force 
             Expand -F:* $Source_Path $Destination_Path
             echo "File Expanded, Installing Please wait..."
                          
             #For 2008 Servers:
             #Important: In the following line please add the $cab_name c:\temp\SWInstall\<cab_name>
             #Invoke-Command -ComputerName $computer {DISM.exe /Online /Add-Package /PackagePath:"c:\temp\SWInstall\(WindowsXX-KBXXXXXXX-x64.cab)"}

             #For 2012 Servers:
             #Invoke-Command -ComputerName $computer {Add-WindowsPackage -Online -PackagePath "C:\temp\SWInstall\WindowsXX-KBXXXXXXX-x64.cab" -NoRestart}
             Invoke-Command -ComputerName $computer {Add-WindowsPackage -Online -PackagePath "C:\temp\SWInstall\windows8.1-kb4103725-x64.cab" -NoRestart}
             echo "Check if the installation was completed"
             }
 
   foreach ($computer in $computers) { #<For> to clean the script file in all servers.
   Remove-Item $Destination_Path -Recurse -Force #cleaning
   Remove-Item \\$computer\$destination\$Package_name -Recurse -Force
   echo 'file cleaned'
   Invoke-Command -ComputerName $computer {Restart-Computer}

   }