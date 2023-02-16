rem @echo off
rem #########################
rem Name	RVToolsBatch
rem By		RobWare
rem Date	November 2013
rem Version	3.6
rem #########################

rem =====================================
rem Include robware/rvtools in searchpath
rem =====================================
set path=%path%;D:\program files (x86)\robware\rvtools;D:\Scripts\Schindler\RVTools


rem =========================
rem Set environment variables
rem =========================
set $VCServer=vcenterscs
set $AttachmentDir=D:\Scripts\Schindler\RVTools\Export_SCS
set $AttachmentFile=RVTools.xls
set $User="SA-PF01-vCSchiRO@itoper.local"
set $PW= "jsN8pnjFcY8c"


set $SMTPserver=smtp.eu.schindler.com
set $SMTPport=25
set $Mailto=antoniovicente.vento@schindler.com
set $Mailfrom=SwisscomvCenterReport@schindler.com
set $Mailsubject=SwisscomvCenterReport

rem ===================
rem Retrieve PW 
rem ===================
rem FOR /F "tokens=1 delims=" %%A in ('powershell.exe GetSecPW.ps1') do SET $PW=%%A

rem ===================
rem Start RVTools batch 
rem ===================
"D:\Program Files (x86)\RobWare\RVTools\rvtools.exe" -u %$User% -p %$PW% -s %$VCServer% -c ExportAll2xls -d %$AttachmentDir% 


rem =========
rem Send mail
rem =========
rvtoolssendmail.exe /smtpserver %$SMTPserver% /smtpport %$SMTPport% /mailto %$Mailto% /mailfrom %$Mailfrom% /mailsubject %$Mailsubject% /attachment %$AttachmentDir%\%$AttachmentFile%
