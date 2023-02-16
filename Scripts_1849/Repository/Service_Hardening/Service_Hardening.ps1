#sc config AudioEndpointBuilder start= disabled
#sc config AudioSrv start= disabled
#sc config FontCache start= disabled
#sc config SCardSvr start= disabled
#sc config ShellHWDetection start= disabled
#sc config TrkWks start= disabled


#Script for HD 2012

$Services_To_Disable = "AudioEndpointBuilder","AudioSrv","FontCache","SCardSvr","ShellHWDetection","TrkWks"


Foreach ($service in $Services_To_Disable)
{

Get-Service -Name $Service | Select-Object -Property name,Status,StartType


}

#Script for HD 2016


$Services_To_Disable = "AudioEndpointBuilder","AudioSrv","FontCache","SCardSvr","ShellHWDetection","TrkWks","XblGameSave","XblAuthManager","bthserv","CDPUserSvc","Browser","PimIndexMaintenanceSvcd","dmwappushservice","MapsBroker","lfsvc","SharedAccess","lltdsvc","wlidsvc","NgcSvc","NgcCtnrSvc","NcbService","PcaSvc","QWAVE","RmSvc","SensorDataService","SensrSvc","SensorService","ShellHWDetection","ScDeviceEnum","SSDPSRV","OneSyncSvc","TabletInputService","UserDataSvc","UnistoreSvc","WalletService","FrameServer","stisvc","wisvc","icssvc"


Foreach ($service in $Services_To_Disable)
{

Get-Service -Name $Service | Select-Object -Property name,Status,StartType


}
































