Import-Module SQLPS

$ServerInstance = "10.10.100.112"
$DB = "MigDB"
$SQLUser = "sa-db-schindlerexport"
$SQLpw = "3d81e118-6859-4d91-8948-f36710de0d91"

New-PSDrive -Name UNCPath -PSProvider FileSystem -Root \\infda001.inf.schindler.com\nubesmigration$\

$SQLquery =@" 
 
SELECT [server].server_name
      ,[rhserver_ls]
      ,[rhserver_lswave]
      ,[rhserver_lsstart]
      ,[rhserver_lsend]
      ,[server].server_site
      ,[server].server_itbc
      ,[server].server_contact
      ,[server].server_contactemail
FROM [MigDB].[dbo].[rhserver],[MigDB].[dbo].[server] WHERE [MigDB].[dbo].[rhserver].rhserver_id = [MigDB].[dbo].[server].server_id 
 
"@ 
 
$result = invoke-sqlcmd -query $SQLquery -serverinstance $ServerInstance -database $DB -Username $SQLUser -Password $SQLpw
$result | export-csv -Path UNCPath:\cloudinator_export_test.csv -NoTypeInformation -Force