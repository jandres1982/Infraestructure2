# You can change the following defaults by altering the below settings:
#


# Set the following to true to enable the setup wizard for first time run
$SetupWizard = $False


# Start of Settings
# Please Specify the address (and optional port) of the server to connect to [servername(:port)]
$Server = "vcentershhdr.global.schindler.com"
# Would you like the report displayed in the local browser once completed ?
$DisplaytoScreen = $true
# Use the following item to define if an email report should be sent once completed
$SendEmail = $false
# Please Specify the SMTP server address
$SMTPSRV = "smtp.eu.schindler.com"
# Would you like to use SSL to send email?
$EmailSSL = $false
# Please specify the email address who will send the vCheck report
$EmailFrom = "shhwsr0025@ch.schindler.com"
# Please specify the email address(es) who will receive the vCheck report (separate multiple addresses with comma)
$EmailTo = "michael.barmettler@ch.schindler.com,bruno.goetschi@ch.schindler.com,erich.niffeler@ch.schindler.com"
# Please specify the email address(es) who will be CCd to receive the vCheck report (separate multiple addresses with comma)
$EmailCc = ""
# Please specify an email subject
$EmailSubject = "Weekly Check"
# Send the report by e-mail even if it is empty?
$EmailReportEvenIfEmpty = $true
# If you would prefer the HTML file as an attachment then enable the following:
$SendAttachment = $true
# Set the style template to use.
$Style = "VMware"
# Set the following setting to $true to see how long each Plugin takes to run as part of the report
$TimeToRun = $true
# Report an plugins that take longer than the following amount of seconds
$PluginSeconds = 30
# End of Settings

# End of Global Variables
