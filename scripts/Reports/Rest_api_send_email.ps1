$flowURI = "https://la-prod-devopsagent-01.azurewebsites.net:443/api/DevOps-http-request-email/triggers/manual/invoke?api-version=2022-05-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=a7roCDH_yxYiGIEwcy2BGaLCHBQt_0yGTX-RTASb-B0"
$Name = "Antonio"
$email = "antoniovicente.vento@schindler.com"
$subject = "Logic App test mail"
$token = "Newsetup.1234567890!"
$params = @{"Name"="$Name";"email"="$email";"subject"="$subject";"token"="$token"}
Invoke-WebRequest -Uri $flowURI -Method POST -ContentType "application/json" -Body ($params|ConvertTo-Json)