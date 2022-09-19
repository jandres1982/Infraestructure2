@ECHO OFF

FOR /F "tokens=1-3 delims=." %%i in ('date/t') do set day=%%i
FOR /F "tokens=1-3 delims=." %%i in ('date/t') do set month=%%j
FOR /F "tokens=1-3 delims=." %%i in ('date/t') do set year=%%k
FOR /F "tokens=1-3 delims=:" %%i in ('time/t') do set hour=%%i
FOR /F "tokens=1-3 delims=:" %%i in ('time/t') do set minute=%%j

set year=%year:~0,4%
set day=%day:~0,2%

REM -----------------------------------------------------------------------------
REM Wrapper for the same-named Powershell script
REM -----------------------------------------------------------------------------

set SCRIPTPATH=d:\Scripts\Schindler\Vmware\Affinity-Rules
set SCRIPTNAME=check-vmdk-affinity-rules

echo %year%-%month%-%day% %hour%:%minute% >> %SCRIPTPATH%\%SCRIPTNAME%.log

powershell.exe %SCRIPTPATH%\%SCRIPTNAME%.ps1 >> %SCRIPTPATH%\%SCRIPTNAME%.log